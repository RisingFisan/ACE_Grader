defmodule AceGraderWeb.SubmissionLive.Show do
  use AceGraderWeb, :live_view
  alias AceGrader.Grader
  # alias AceGrader.Exercises
  alias AceGrader.Submissions

  def mount(_params = %{"id" => id, "exercise_id" => exercise_id}, _assigns, socket) do
    submission = Submissions.get_submission!(id)
    IO.inspect(submission)
    if socket.assigns.current_user.account_type == :student && submission.author_id != socket.assigns.current_user.id do
      {:ok, socket |> put_flash(:error, "You do not have permission to view this submission.") |> push_navigate(to: "/exercises/#{exercise_id}")}
    else
      socket = assign(socket, submission: submission)

      if connected?(socket) && submission.status == :pending && AceGrader.Grader.APIStatus.get_status() == :online do
        liveview = self()
        Task.async(fn -> Grader.grade_submission(submission, liveview) end)
      end

      {:ok, socket}
    end
  end

  def handle_info({:compilation_warnings, warnings}, socket) do
    {:noreply, socket |> update(:submission, fn s -> %{s | warnings: warnings} end)}
  end

  # def handle_info({:test_result, test_id, output, _i}, socket) do
  #   {:noreply, socket |> update(:submission, fn s -> %{s | tests: List.foldr(s.tests, [], & [ (if &1.id == test_id, do: Map.put(&1, :actual_output, output), else: &1) | &2])} end)}
  # end

  def handle_info({ref, result}, socket) do
    Process.demonitor(ref, [:flush]) # we flush the process before it dies, since we already have the result, and avoid needing another handle_info for the death message
    case result do
      {:ok, submission} -> {:noreply, socket |> assign(submission: submission)}
      {:error, _changeset} ->
        {:noreply, socket |> put_flash(:error, "Error grading submission! Please reload the page.")}
      {:retry, error_msg} ->
        {:noreply, socket |> put_flash(:error, error_msg)}
    end
  end

end
