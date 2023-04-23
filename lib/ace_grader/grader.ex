defmodule AceGrader.Grader do
  alias AceGrader.Submissions
  alias AceGrader.Submissions.Submission

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
          |> Enum.all?(& &1 =~ output)
      end), do: :success, else: :failed),
      String.trim(output)
    }
  end
  defp process_output(_test, %{"status" => "timeout"}) do
    {:timeout, ""}
  end
  defp process_output(_test, %{"status" => "error", "output" => error_msg}) do
    {:error, error_msg}
  end

  defp compile(submission, id) do
    case HTTPoison.post("127.0.0.1:5000/compile", Jason.encode!(%{
      "id" => id,
      "code" => submission.code,
      "test_file" => submission.exercise.test_file
    }), [{"Content-Type", "application/json"}]) do
      {:ok, response} ->
        case Jason.decode!(response.body) do
          %{"status" => "success", "output" => warnings} ->
            {:ok, warnings}
          %{"status" => "error", "output" => error_msg} ->
            {:error, error_msg}
        end
      {:error, error} ->
        {:error, to_string(error.reason)}
    end

    # File.write("#{path}/sub.c", submission.code)
    # File.write("#{path}/main.c", submission.exercise.test_file)
    # case System.cmd("gcc", ~w(main.c sub.c -o main), stderr_to_stdout: true, cd: path) do
    #   {warnings, 0} ->
    #     {:ok, warnings}
    #   {warnings, _} ->
    #     {:error, warnings}
    # end
  end

  def run(submission, id, liveview \\ nil) do
    case compile(submission, id) do
      {:ok, warnings} ->
        if warnings != "" and liveview != nil, do: send(liveview, {:compilation_warnings, warnings})
        tests = for {test, _i} <- submission.tests |> Enum.with_index(1), liveview != nil or test.visible do
          Task.async(fn ->
            if test.status == :pending do
              {_status, response} = HTTPoison.post("127.0.0.1:5000/test", Jason.encode!(%{"id" => id, "input" => (test.input || "")}), [{"Content-Type", "application/json"}]) # System.cmd("python", [File.cwd!() <> "/runner.py", "#{path}/main", test.input || ""])
              {status, output} = process_output(test, Jason.decode!(response.body))
              # if liveview != nil do
              #   send(liveview, {:test_result, test.id, output, i})
              # end
              %{ Map.from_struct(test) | actual_output: output, status: status }
            else
              test
            end
          end)
        end
        |> Task.await_many(10_000)
        total_grade = Enum.reduce(tests, 0, fn test, acc -> (if test.status == :success, do: acc + test.grade, else: acc) end)
        %{success: true, warnings: warnings, total_grade: total_grade, tests: Enum.filter(tests, & &1.status != :pending)}
      {:error, error_msg} ->
        %{success: false, errors: error_msg, total_grade: 0, tests: Enum.map(submission.tests, fn test -> %{ Map.from_struct(test) | status: :error} end)}
    end
  end

  def grade_submission(submission, liveview) do
    if Submission.pending_tests(submission) do
      attrs = run(submission, submission.id, liveview)
      Submissions.update_submission(submission, attrs)
    else
      {:ok, submission}
    end
  end

  def test_submission(submission) do
    attrs = run(submission, submission.author_id)
    submission
    |> Submission.changeset(attrs)
    |> Ecto.Changeset.apply_changes()
  end
end

# sudo chmod -R a+rwx
