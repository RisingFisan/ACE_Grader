defmodule AceGrader.Grader do
  alias AceGrader.Submissions
  alias AceGrader.Submissions.Submission

  def run(%Submission{} = submission) do
    File.write("./submissions/main.c", submission.code)
    case System.cmd("gcc", ~w(./submissions/main.c -o ./submissions/main), stderr_to_stdout: true) do
      {warnings, 0} ->
        {output, _exit_status} = System.shell("./submissions/main", [])
        %{ executed: true, success: true, output: output, warnings: warnings }
      {errors, n} ->
        %{ executed: true, success: false, output: "", errors: errors }
    end
    |> (fn attrs ->
      case Submissions.update_submission(submission, attrs) do
        {:ok, new_submission} -> new_submission
        {:error, _} -> nil
      end
    end).()
  end
end
