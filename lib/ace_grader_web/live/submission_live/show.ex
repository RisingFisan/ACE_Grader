defmodule AceGraderWeb.SubmissionLive.Show do
  use AceGraderWeb, :live_view
  alias AceGrader.Exercises
  alias AceGrader.Submissions

  def mount(_params = %{"id" => id, "exercise_id" => exercise_id}, _session, socket) do
    submission = Submissions.get_submission!(id)
    |> Map.put(:exercise, Exercises.get_exercise!(exercise_id, false))
    socket = assign(socket, submission: submission)
    # if not submission.executed do
    #   Task.async(fn ->
    #     %{submission: AceGrader.Grader.run(submission)}
    #   end)
    # end
    if not submission.executed do
      File.write("./submissions/main.c", submission.code)
      attrs = case System.cmd("gcc", ~w(main.c -o main), stderr_to_stdout: true, cd: "./submissions") do
        {warnings, 0} ->
          test_results = for {test, i} <- submission.tests |> Enum.with_index(1) do
            Task.async(fn ->
              {output, _exit_status} = System.cmd(File.cwd!() <> "/submissions/main", (if test.input != nil, do: String.split(test.input), else: []))
              {test.id, output, i}
            end)
          end
          %{executed: true, warnings: warnings}
        {errors, n} ->
          %{executed: true, errors: errors}
      end
    end
    Submissions.update_submission(submission, %{executed: true})
    # CHANGE THIS SO THAT THE EXECUTED PARAMETER BELONGS TO EACH TEST
    {:ok, socket}
  end

  def handle_info({ref, {test_id, output, i}}, socket) do
    Process.demonitor(ref, [:flush]) # we flush the process before it dies, since we already have the result, and avoid needing another handle_info for the death message
    test = Submissions.get_test!(test_id)
    case Submissions.update_test(test, %{actual_output: output}) do
      {:ok, new_test} -> {:noreply, socket |> update(:submission, fn s -> %{s | tests: List.foldr(s.tests, [], & [ (if &1.id == test_id, do: new_test, else: &1) | &2])} end)}
      {:error, _} -> {:noreply, socket |> put_flash(:error, "Error running test #{i}!")}
    end
  end

end
