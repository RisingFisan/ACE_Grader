defmodule AceGraderWeb.ExerciseLive.Show do
  use AceGraderWeb, :live_view
  alias AceGrader.Exercises
  alias AceGrader.Submissions

  import Ecto.Changeset

  @page_size 10

  def handle_params(params, _url, socket) do
    changeset = params |> order_and_filter_changeset()
    submissions = fetch_submissions(socket.assigns.exercise, socket.assigns.current_user, changeset |> apply_changes(), 1)
    {
      :noreply,
      socket
      |> assign(:order_and_filter_changeset, changeset)
      |> assign(:page, (if length(submissions) == @page_size, do: 1, else: -1))
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

  def handle_event("load_more_submissions", _params, socket) do
    params = socket.assigns.order_and_filter_changeset |> apply_changes()
    page = socket.assigns.page + 1
    submissions = fetch_submissions(socket.assigns.exercise, socket.assigns.current_user, params, page)
    if length(submissions) == @page_size do
      {:noreply, socket
      |> assign(:page, page)
      |> stream(:submissions, submissions, at: -1)}
    else
      {:noreply, socket |> assign(:page, -1)}
    end
  end

  defp order_and_filter_changeset(attrs) do
    cast(
      {%{order_by: "date_desc", unique: false}, %{order_by: :string, unique: :boolean}},
      attrs,
      [:order_by, :unique]
    )
  end

  defp fetch_submissions(_, nil, _, _), do: []
  defp fetch_submissions(exercise, user, %{order_by: _, unique: _} = params, page) do
    case Map.get(user, :account_type) do
      :student ->
        Submissions.get_exercise_user_submissions(exercise, user, params, page, @page_size)
      _ ->
        Submissions.fetch_submissions(exercise, params, page, @page_size)
    end
  end
end
