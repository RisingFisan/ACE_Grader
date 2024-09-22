defmodule AceGraderWeb.ExerciseLive.Show do
  use AceGraderWeb, :live_view
  alias AceGrader.Exercises
  alias AceGrader.Submissions

  import Ecto.Changeset

  def handle_params(params, _url, socket) do
    submissions = case Map.get(socket.assigns.current_user || %{}, :account_type, nil) do
      :student ->
        Submissions.get_exercise_user_submissions(socket.assigns.exercise, socket.assigns.current_user, params)
      :teacher ->
        Submissions.get_exercise_submissions(socket.assigns.exercise, params)
      _ ->
        []
    end
    {
      :noreply,
      socket
      |> assign(:order_and_filter_changeset, order_and_filter_changeset(params))
      |> stream(:submissions, submissions, reset: true)
    }
  end

  def mount(_params = %{"id" => id}, _session, socket) do
    exercise = Exercises.get_exercise!(id)
    {:ok, socket
      |> assign(
        show_delete: Application.get_env(:ace_grader, :dev_routes),
        exercise: exercise,
        page_title: exercise.title,
        is_owner: socket.assigns.current_user != nil and exercise.author_id == socket.assigns.current_user.id
      )}
  end

  def handle_event("prompt_download", %{"file-type" => file_type}, socket) do
    data = case file_type do
      "json" ->
        submissions = Submissions.get_exercise_submissions(socket.assigns.exercise)
        |> Enum.map(fn submission -> AceGrader.Submissions.Submission.to_map(submission) end)

        %{
          exercise: socket.assigns.exercise,
          submissions: submissions
        }
        |> Jason.encode!()
        |> Jason.Formatter.pretty_print()

      "csv" -> "hello world"
    end

    {:noreply, socket |> push_event("prompt_download", %{
      "content" => data,
      "filename" => "submissions",
      "filetype" => file_type
    })}
  end

  def handle_event("order_and_filter", %{"order_and_filter" => order_and_filter_params}, socket) do
    order_and_filter_params
    |> order_and_filter_changeset()
    |> case do
      %{valid?: true} = changeset ->
        {
          :noreply,
          socket
          |> push_patch(to: ~p"/exercises/#{socket.assigns.exercise.id}?#{apply_changes(changeset)}")
        }
      _ ->
        {:noreply, socket}
    end
  end

  defp order_and_filter_changeset(attrs) do
    cast(
      {%{order_by: "date_desc", unique: false}, %{order_by: :string, unique: :boolean}},
      attrs,
      [:order_by, :unique]
    )
  end
end
