defmodule AceGraderWeb.ExerciseLive.Editor do
  use AceGraderWeb, :live_view
  alias AceGrader.Exercises
  alias AceGrader.Submissions

  def mount(_params = %{"id" => id}, _session, socket) do
    exercise = Exercises.get_exercise!(id)
    submission = %Submissions.Submission{}
    changeset = Submissions.change_submission(submission)
    |> Ecto.Changeset.put_assoc(:tests, (for test <- exercise.tests do
      struct(%Submissions.Test{}, test
        |> Map.from_struct()
        |> Map.take([:grade, :input, :type, :expected_output, :visible]))
    end))

    socket = assign(socket, exercise: exercise)
    |> assign(warnings: nil, errors: nil, confirm_modal: false)
    |> assign(test_results: nil)
    |> assign(submission: changeset)
    {:ok, socket}
  end

  def handle_event("test_code", %{"code" => code}, socket) do
    File.write("./submissions/main.c", code)
    case System.cmd("gcc", ~w(main.c -o main), stderr_to_stdout: true, cd: "./submissions") do
      {warnings, 0} ->
        live_view = self()
        test_results = for {test, i} <- socket.assigns.exercise.tests |> Enum.with_index(), test.visible do
          Task.start(fn ->
            {output, _exit_status} = System.cmd(File.cwd!() <> "/submissions/main", (if test.input != nil, do: String.split(test.input), else: []))
            send(live_view, {:test_result, {i, output}})
          end)
        end
        {:noreply, assign(socket, test_results: Enum.map(socket.assigns.exercise.tests, fn test -> Map.put(test, :actual_output, nil) end))}
      {errors, n} ->
        {:noreply, socket
        |> put_flash(:error, "Error #{n}")
        |> assign(warnings: nil, errors: errors)}
    end
  end

  def handle_event("submit_code", %{"submission" => submission_params} = _params, socket) do
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

  def handle_info({:test_result, {i, output}}, socket) do
    {:noreply, update(socket, :test_results, fn tests -> List.update_at(tests, i, fn test -> Map.put(test, :actual_output, output) end) end)}
  end
end
