defmodule AceGraderWeb.ExerciseLive.Editor do
  use AceGraderWeb, :live_view
  alias AceGrader.Exercises
  alias AceGrader.Submissions
  alias AceGrader.Grader

  def mount(_params = %{"id" => id}, _session, socket) do
    exercise = Exercises.get_exercise!(id, false)
    submission = %Submissions.Submission{exercise: exercise}
    changeset = Submissions.change_submission(submission)
    |> Ecto.Changeset.put_assoc(:tests, (for test <- exercise.tests do
      struct(%Submissions.Test{}, test
        |> Map.from_struct()
        |> Map.take([:grade, :input, :type, :expected_output, :visible]))
    end))
    |> Ecto.Changeset.put_change(:author_id, socket.assigns.current_user.id)

    socket = assign(socket, exercise: exercise)
    |> assign(warnings: nil, errors: nil, confirm_modal: false)
    |> assign(test_results: nil, testing: false, success: nil)
    |> assign(submission: changeset)
    {:ok, socket |> assign(page_title: "Exercise Editor")}
  end

  def handle_event("pre_test_code", _params, socket) do
    {:noreply, socket
      |> assign(
        test_results: nil,
        success: nil,
        testing: true
      )}
  end

  def handle_event("test_code", %{"code" => code}, socket) do
    submission = socket.assigns.submission
    |> Ecto.Changeset.cast(%{code: code}, [:code])
    |> Ecto.Changeset.apply_changes

    submission = Grader.test_submission(submission)

    {:noreply, socket
      |> assign(
        success: submission.success,
        test_results: submission.tests |> IO.inspect(),
        warnings: submission.warnings,
        errors: submission.errors,
        testing: false)}
  end

  def handle_event("submit_code", %{"submission" => submission_params} = _params, socket) do
    submission_params = Map.put(submission_params, "author_id", socket.assigns.current_user.id)
    case Submissions.create_submission(submission_params) do
      {:ok, submission} ->
        {:noreply, push_navigate(socket, to: ~p"/exercises/#{submission.exercise_id}/submissions/#{submission}")}
      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply, socket |> put_flash(:error, "Error creating submission")}
    end
  end

  def handle_event("show_confirm", _params, socket) do
    {:noreply, assign(socket, confirm_modal: true)}
  end

  def handle_event("hide_confirm", _params, socket) do
    {:noreply, assign(socket, confirm_modal: false)}
  end
end
