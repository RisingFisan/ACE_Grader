defmodule AceGraderWeb.ExerciseLive.Editor do
  use AceGraderWeb, :live_view
  alias AceGrader.Exercises
  alias AceGrader.Submissions
  alias AceGrader.Grader

  def mount(_params = %{"id" => id}, _session, socket) do
    exercise = Exercises.get_exercise!(id)
    submission = %Submissions.Submission{}
    attrs = %{
      exercise_id: exercise.id,
      author_id: socket.assigns.current_user.id,
      tests: Enum.map(exercise.tests, fn test -> Map.from_struct(test) end),
      parameters: Enum.map(exercise.parameters, fn parameter -> Map.from_struct(parameter) end)
    }
    # |> Ecto.Changeset.put_assoc(:tests, (for test <- exercise.tests do
    #   struct(%Submissions.Test{}, test
    #     |> Map.from_struct()
    #     |> Map.take([:grade, :input, :type, :expected_output, :visible, :description]))
    # end))

    socket = assign(socket, exercise: exercise)
    |> assign(compilation_msg: nil, confirm_modal: false, expanded: 0, description: true)
    |> assign(test_results: nil, testing: false, success: nil, wrapped: 0)
    |> assign(code: exercise.template || "")
    |> assign(attrs: attrs)
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

  def handle_event("test_code", _params, socket) do
    submission = Submissions.change_submission(%Submissions.Submission{}, socket.assigns.attrs)
    |> Ecto.Changeset.cast(%{code: socket.assigns.code}, [:code])
    |> Ecto.Changeset.apply_changes
    |> Map.put(:exercise, socket.assigns.exercise)

    Task.async(fn ->
      Grader.test_submission(submission, socket.assigns.current_user)
    end)

    {:noreply, assign(socket, testing: true, success: nil)}
  end

  def handle_event("update_code", %{"submission" => %{"code" => code}} = _params, socket) do
    {:noreply, socket |> assign(:code, code)}
  end

  def handle_event("submit_code", %{"submission" => %{"code" => code}} = _params, socket) do
    case Submissions.create_submission(Map.put(socket.assigns.attrs, :code, code)) do
      {:ok, submission} ->
        {:noreply, push_navigate(socket, to: ~p"/exercises/#{submission.exercise_id}/submissions/#{submission}")}
      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply, socket |> put_flash(:error, "Error creating submission!")}
    end
  end

  def handle_event("show_confirm", _params, socket) do
    {:noreply, assign(socket, confirm_modal: true)}
  end

  def handle_event("hide_confirm", _params, socket) do
    {:noreply, assign(socket, confirm_modal: false)}
  end

  def handle_event("expand_editor", %{"expand" => expand} = _assigns, socket) do
    expand? = expand == "0"
    {:noreply, socket |> push_event("expand_editor", %{"expand" => expand?}) |> assign(expanded: (if expand?, do: 1, else: 0))}
  end

  def handle_event("text_wrap", %{"wrap" => wrap} = _assigns, socket) do
    wrap? = wrap == "0"
    {:noreply, socket |> push_event("text_wrap", %{"wrap" => wrap?}) |> assign(wrapped: (if wrap?, do: 1, else: 0))}
  end

  def handle_info({ref, result}, socket) when is_reference(ref) do
    Process.demonitor(ref, [:flush])

    socket = assign(socket, testing: false)

    case result do
      {:ok, params} ->
        {:noreply, socket
        |> assign(params)
        |> assign(%{success: true})}
      {:error, params} ->
        {:noreply, socket
        |> assign(params)
        |> assign(%{success: false})}
      {:retry, msg} ->
        {:noreply, socket
        |> put_flash(:error, msg)
        |> assign(%{success: nil})}
    end
  end
end
