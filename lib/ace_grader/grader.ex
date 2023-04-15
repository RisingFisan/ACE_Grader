defmodule AceGrader.Grader do
  alias AceGrader.Submissions
  alias AceGrader.Submissions.Submission

  def run(submission, test_file, path, liveview \\ nil) do
    File.write("./#{path}/sub.c", submission.code)
    File.write("./#{path}/main.c", test_file)
    case System.cmd("gcc", ~w(main.c sub.c -o main), stderr_to_stdout: true, cd: path) do
      {warnings, 0} ->
        if warnings != "" and liveview != nil, do: send(liveview, {:compilation_warnings, warnings})
        tests = for {test, i} <- submission.tests |> Enum.with_index(1), liveview != nil or test.visible do
          Task.async(fn ->
            if test.status == :pending do
              {output, _exit_status} = System.cmd("python", [File.cwd!() <> "/runner.py", File.cwd!() <> "/#{path}/main", test.input || ""])
              {status, output} = case output do
                "SUCCESS" <> output ->
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
                "TIMEOUT" <> _ -> {:timeout, ""}
                "ERROR" <> error_msg -> {:error, error_msg}
              end
              if liveview != nil do
                send(liveview, {:test_result, test.id, output, i})
                %{ Map.from_struct(test) | actual_output: output, status: status }
              else
                %{test | actual_output: output, status: status}
              end
            else
              Map.from_struct(test)
            end
          end)
        end
        |> Task.await_many(10_000)
        total_grade = Enum.reduce(tests, 0, fn test, acc -> (if test.status == :success, do: acc + test.grade, else: acc) end)
        %{success: true, warnings: warnings, total_grade: total_grade, tests: tests}
      {errors, _n} ->
        %{success: false, errors: errors, total_grade: 0}
    end
  end

  def grade_submission(submission, test_file, liveview) do
    if Submission.pending_tests(submission) do
      path = "submissions/#{submission.id}"
      File.mkdir_p!(path)
      attrs = run(submission, test_file, path, liveview)
      File.rm_rf!(path)
      Submissions.update_submission(submission, attrs)
    else
      {:ok, submission}
    end
  end

  def test_submission(submission, test_file) do
    path = "submissions/#{submission.author_id}"
    File.mkdir_p!(path)
    attrs = run(submission, test_file, path)
    File.rm_rf!(path)
    submission
    |> Map.put(:warnings, attrs[:warnings])
    |> Map.put(:errors, attrs[:errors])
    |> Map.put(:success, attrs[:success])
    |> Map.put(:tests, attrs[:tests] || submission.tests)
  end
end
