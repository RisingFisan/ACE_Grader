defmodule AceGrader.Grader do
  alias AceGrader.Submissions
  alias AceGrader.Submissions.Submission

  def run(submission, liveview \\ nil) do
    File.write("./submissions/main.c", submission.code)
    case System.cmd("gcc", ~w(main.c -o main), stderr_to_stdout: true, cd: "./submissions") do
      {warnings, 0} ->
        if warnings != "" and liveview != nil, do: send(liveview, {:compilation_warnings, warnings})
        test_results = for {test, i} <- submission.tests |> Enum.with_index(1), not test.executed do
          Task.async(fn ->
            {output, _exit_status} = System.cmd(File.cwd!() <> "/submissions/main", (if test.input != nil, do: String.split(test.input), else: []))
            if liveview != nil do
              send(liveview, {:test_result, test.id, output, i})
              %{id: test.id, executed: true, actual_output: output}
            else
              %{test | executed: true, actual_output: output}
            end
          end)
        end
        |> Task.await_many()
        %{success: true, warnings: warnings, tests: test_results}
      {errors, _n} ->
        %{success: false, errors: errors}
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
