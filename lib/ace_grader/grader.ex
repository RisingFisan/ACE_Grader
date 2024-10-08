defmodule AceGrader.Grader do
  alias AceGrader.Submissions
  alias AceGrader.Grader.API

  defp process_output(test, %{"status" => "success", "output" => output}) do
    {
      (if (case test.type do
        :exact ->
          String.trim(output) == String.trim(test.expected_output)
        :regex ->
          Regex.compile!(test.expected_output)
          |> Regex.match?(output)
        :items ->
          String.split(test.expected_output, "\n")
          |> Enum.all?(& output =~ &1)
      end), do: :success, else: :failed),
      String.trim(output)
    }
  end
  defp process_output(_test, %{"status" => "timeout"}) do
    {:timeout, ""}
  end
  defp process_output(_test, %{"status" => "error", "output" => error_msg, "code" => error_code}) do
    case error_code do
      11 -> {:error, "Segmentation fault"}
      _ -> {:error, error_msg}
    end
  end

  defp process_parameters_output(_, %{"status" => "error"}), do: []
  defp process_parameters_output(parameters, results) do
    results = Map.new(results, fn
      %{"key" => key, "error" => _} -> {key, nil}
      %{"key" => key, "result" => result} -> {key, result}
    end)
    for parameter <- parameters do
      result = Map.get(results, parameter.key)
      status = cond do
        result == nil -> :error
        parameter.negative and !result or !parameter.negative and result -> :success
        true -> :failed
      end
      Map.from_struct(%{parameter | status: status})
    end
  end

  defp compile(submission) do
    case HTTPoison.post(API.grader_url() <> "/compile", Jason.encode!(%{
      "code" => submission.code,
      "test_file" => submission.exercise.test_file,
      "language" => submission.exercise.language
    }), [{"Content-Type", "application/json"}]) do
      {:ok, %HTTPoison.Response{status_code: 500}} ->
        {:error, "Internal server error."}
      {:ok, response} ->
        case Jason.decode!(response.body) do
          %{"status" => "success", "output" => warnings, "id" => grader_id} ->
            {:ok, grader_id, warnings}
          %{"status" => "timeout"} ->
            {:error, "Server timeout."}
          %{"status" => "error", "output" => error_msg} ->
            {:error, error_msg}
        end
      {:error, error} ->
        case error do
          %HTTPoison.Error{reason: reason} when reason in [:econnrefused, :connect_timeout] ->
            {:retry, "Internal server error - grader is offline. Please try again later."}
          %HTTPoison.Error{reason: :timeout} ->
            {:retry, "Unexpected server timeout. Sometimes this happens and I still haven't figured out why. Just try again and it should work... probably."}
          _ ->
            IO.inspect(error)
            {:retry, "Unexpected error."}
        end
    end
  end

  def grade_submission(submission, liveview) do
    if submission.status == :pending do
      case compile(submission) do
        {:ok, grader_id, warnings} ->
          send(liveview, {:compilation_warnings, warnings})
          tests_async = for test <- submission.tests do
            Task.async(fn ->
              if test.status == :pending or test.status == :error do
                {_status, response} = HTTPoison.post(API.grader_url() <> "/execute", Jason.encode!(%{
                  "id" => grader_id,
                  "input" => (test.input || "")}), [{"Content-Type", "application/json"}]) # System.cmd("python", [File.cwd!() <> "/runner.py", "#{path}/main", test.input || ""])
                case response do
                  %HTTPoison.Error{reason: :timeout} ->
                    %{ Map.from_struct(test) | status: :timeout }
                  response ->
                    {status, output} = process_output(test, Jason.decode!(response.body))
                    # send(liveview, {:test_result, test.id, output, i})
                    %{ Map.from_struct(test) | actual_output: output, status: status }
                end
              else
                Map.from_struct(test)
              end
            end)
          end

          parameters =
            Task.async(fn ->
              {_status, response} = HTTPoison.post(API.grader_url() <> "/analyze", Jason.encode!(%{
                "id" => grader_id,
                "language" => submission.exercise.language,
                "params" => Enum.map(submission.parameters, fn parameter -> %{
                  "key" => parameter.key,
                  "value" => parameter.value
                } end)
              }), [{"Content-Type", "application/json"}])
              process_parameters_output(submission.parameters, Jason.decode!(response.body))
            end) |> Task.await()

          tests = Task.await_many(tests_async, 10_000)

          mandatory_params = Enum.filter(parameters, fn parameter -> parameter.type == :mandatory end)
          total_grade =
            if Enum.all?(mandatory_params, fn parameter -> parameter.status == :success end) do
              Kernel.+(
                Enum.reduce(tests, 0, fn test, acc -> (if test.status == :success, do: acc + test.grade, else: acc) end),
                Enum.reduce(parameters, 0, fn parameter, acc -> (if parameter.status == :success and parameter.type == :graded, do: acc + parameter.grade, else: acc) end)
              )
            else
              0
            end
          Submissions.update_submission(submission, %{status: :success, warnings: warnings, errors: nil, total_grade: total_grade, tests: tests, parameters: parameters})
        {:error, error_msg} ->
          Submissions.update_submission(submission, %{
            status: :error,
            errors: error_msg,
            total_grade: 0,
            tests: Enum.map(submission.tests, fn test -> %{ Map.from_struct(test) | status: :error} end),
            parameters: Enum.map(submission.parameters, fn parameter -> %{ Map.from_struct(parameter) | status: :error} end)
          })
        {:retry, error_msg} ->
          {:retry, error_msg}
      end
    else
      {:ok, submission}
    end
  end

  def test_submission(submission, user) do
    case compile(submission) do
      {:ok, grader_id, warnings} ->
        tests_async = for test <- submission.tests, test.visible || submission.exercise.author_id == user.id do
          Task.async(fn ->
            {_status, response} = HTTPoison.post(API.grader_url() <> "/execute", Jason.encode!(%{
              "id" => grader_id,
              "input" => (test.input || "")}), [{"Content-Type", "application/json"}])
            case response do
              %HTTPoison.Error{reason: :timeout} ->
                %{ Map.from_struct(test) | status: :timeout }
              response ->
                {status, output} = process_output(test, Jason.decode!(response.body))
                %{ Map.from_struct(test) | actual_output: output, status: status }
            end
          end)
        end
        parameters = if length(submission.parameters) > 0 do
          Task.async(fn ->
            {_status, response} = HTTPoison.post(API.grader_url() <> "/analyze", Jason.encode!(%{
              "id" => grader_id,
              "params" => Enum.map(Enum.filter(submission.parameters, & &1.visible), fn parameter -> %{
                "key" => parameter.key,
                "value" => parameter.value
              } end),
              "language" => submission.exercise.language
            }), [{"Content-Type", "application/json"}])
            process_parameters_output(submission.parameters, Jason.decode!(response.body))
          end) |> Task.await()
        else
          []
        end
        tests = Task.await_many(tests_async, 10_000)
        {:ok, %{compilation_msg: warnings, test_results: tests, parameter_results: parameters}}
      {:error, error_msg} ->
        {:error, %{compilation_msg: error_msg, test_results: Enum.map(submission.tests, fn test -> %{ Map.from_struct(test) | status: :error} end), parameter_results: Enum.map(submission.parameters, fn parameter -> %{ Map.from_struct(parameter) | status: :error} end)}}
      {:retry, error_msg} ->
        {:retry, error_msg}
    end
  end
end
