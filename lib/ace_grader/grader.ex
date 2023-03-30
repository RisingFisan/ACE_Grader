defmodule AceGrader.Grader do
  alias AceGrader.Submissions

  def run(submission, liveview \\ nil) do
    File.write("./submissions/main.c", submission.code)
    case System.cmd("gcc", ~w(main.c -o main), stderr_to_stdout: true, cd: "./submissions") do
      {warnings, 0} ->
        if warnings != "" and liveview != nil, do: send(liveview, {:compilation_warnings, warnings})
        tests = for {test, i} <- submission.tests |> Enum.with_index(1), liveview != nil or test.visible do
          Task.async(fn ->
            if not test.executed do
              {output, _exit_status} = System.cmd("python", [File.cwd!() <> "/submissions/runner.py", File.cwd!() <> "/submissions/main", test.input || ""])
              output = String.trim_trailing(output, "\n")
              passed = case test.type do
                :exact ->
                  String.trim(output) == String.trim(test.expected_output)
                :regex ->
                  Regex.compile!(test.expected_output)
                  |> Regex.match?(output)
                :items ->
                  String.split(test.expected_output, "\n")
                  |> Enum.all?(& &1 =~ output)
              end
              if liveview != nil do
                send(liveview, {:test_result, test.id, output, i})
                %{ Map.from_struct(test) | executed: true, actual_output: output, passed: passed}
              else
                %{test | executed: true, actual_output: output, passed: passed}
              end
            else
              Map.from_struct(test)
            end
          end)
        end
        |> Task.await_many()
        total_grade = Enum.reduce(tests, 0, fn test, acc -> (if test.passed, do: acc + test.grade, else: acc) end)
        %{success: true, warnings: warnings, total_grade: total_grade, tests: tests}
      {errors, _n} ->
        %{success: false, errors: errors, total_grade: 0}
    end
  end

  def grade_submission(submission, liveview) do
    tests = Enum.filter(submission.tests, & not &1.executed)
    if length(tests) > 0 do
      attrs = run(submission, liveview)
      Submissions.update_submission(submission, attrs)
    else
      {:ok, submission}
    end
  end

  def test_submission(submission) do
    attrs = run(submission)
    submission
    |> Map.put(:warnings, attrs[:warnings])
    |> Map.put(:errors, attrs[:errors])
    |> Map.put(:success, attrs[:success])
    |> Map.put(:tests, attrs[:tests] || submission.tests)
  end
end
