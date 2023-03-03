defmodule AceGraderWeb.ExerciseLive.Editor do
  use AceGraderWeb, :live_view
  alias AceGrader.Exercises
  alias AceGrader.Submissions

  def mount(_params = %{"id" => id}, _session, socket) do
    socket = assign(socket, exercise: Exercises.get_exercise!(id))
    |> assign(warnings: nil, errors: nil, output: nil, confirm_modal: false)
    |> assign(submission: Submissions.change_submission(%Submissions.Submission{}))
    {:ok, socket}
  end

  def handle_event("test_code", %{"code" => code}, socket) do
    File.write("./submissions/main.c", code)
    case System.cmd("gcc", ~w(./submissions/main.c -o ./submissions/main), stderr_to_stdout: true) do
      {warnings, 0} ->
        {output, _exit_status} = System.shell("./submissions/main", [])
        IO.inspect(warnings)
        {:noreply, socket
        |> assign(output: output)
        |> assign(warnings: (if warnings == "", do: nil, else: warnings), errors: nil)}
      {errors, n} ->
        {:noreply, socket
        |> put_flash(:error, "Error #{n}")
        |> assign(warnings: nil, errors: errors, output: nil)}
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
end
