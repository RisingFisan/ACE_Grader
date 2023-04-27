defmodule AceGraderWeb.ExerciseLive.Editor do
  use AceGraderWeb, :live_view
  alias AceGrader.Exercises
  alias AceGrader.Submissions
  alias AceGrader.Grader

  def mount(_params = %{"id" => id}, _session, socket) do
    exercise = Exercises.get_exercise!(id, false)
    submission = %Submissions.Submission{}
    attrs = %{
      exercise_id: exercise.id,
      author_id: socket.assigns.current_user.id,
      tests: Enum.map(exercise.tests, fn test -> Map.from_struct(test) end)
    }
    # |> Ecto.Changeset.put_assoc(:tests, (for test <- exercise.tests do
    #   struct(%Submissions.Test{}, test
    #     |> Map.from_struct()
    #     |> Map.take([:grade, :input, :type, :expected_output, :visible, :description]))
    # end))

    socket = assign(socket, exercise: exercise)
    |> assign(compilation_msg: nil, confirm_modal: false)
    |> assign(test_results: nil, testing: false, success: nil)
    |> assign(attrs: attrs |> IO.inspect())
    |> assign(changeset: Submissions.change_submission(submission, attrs))
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
    submission = Submissions.change_submission(%Submissions.Submission{}, socket.assigns.attrs)
    |> Ecto.Changeset.cast(%{code: code}, [:code])
    |> Ecto.Changeset.apply_changes
    |> Map.put(:exercise, socket.assigns.exercise)

    result = Grader.test_submission(submission)

    {:noreply, socket
      |> assign(
        success: result.success,
        test_results: result.tests,
        compilation_msg: result.compilation_msg,
        testing: false)}
  end

  def handle_event("submit_code", %{"submission" => %{"code" => code}} = _params, socket) do
    case Submissions.create_submission(Map.put(socket.assigns.attrs, :code, code)) do
      {:ok, submission} ->
        {:noreply, push_navigate(socket, to: ~p"/exercises/#{submission.exercise_id}/submissions/#{submission}")}
      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset.errors)
        {:noreply, socket |> put_flash(:error, "Error creating submission!")}
    end
  end

  def handle_event("show_confirm", _params, socket) do
    {:noreply, assign(socket, confirm_modal: true)}
  end

  def handle_event("hide_confirm", _params, socket) do
    {:noreply, assign(socket, confirm_modal: false)}
  end
end
