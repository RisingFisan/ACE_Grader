defmodule AceGraderWeb.SubmissionLive.Show do
  use AceGraderWeb, :live_view
  alias AceGrader.Exercises
  alias AceGrader.Submissions

  def mount(_params = %{"id" => id, "exercise_id" => exercise_id}, _session, socket) do
    submission = Submissions.get_submission!(id) |> Map.put(:exercise, Exercises.get_exercise!(exercise_id, false))
    socket = assign(socket, submission: submission)
    if not submission.executed do
      Task.async(fn ->
        %{submission: AceGrader.Grader.run(submission)}
      end)
    end
    {:ok, socket}
  end

  def handle_info({ref, result}, socket) do
    Process.demonitor(ref, [:flush]) # we flush the process before it dies, since we already have the result, and avoid needing another handle_info for the death message
    {:noreply, assign(socket, result)}
  end

end
