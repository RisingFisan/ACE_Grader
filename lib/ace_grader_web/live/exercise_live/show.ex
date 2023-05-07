defmodule AceGraderWeb.ExerciseLive.Show do
  use AceGraderWeb, :live_view
  alias AceGrader.Exercises

  import Ecto.Changeset

  def handle_params(params = %{"id" => id}, _url, socket) do
    exercise = Exercises.get_exercise!(id, true, params)
    exercise = if socket.assigns.current_user.account_type == :student do
      %{exercise | submissions: Enum.filter(exercise.submissions, &(&1.author_id == socket.assigns.current_user.id))}
    else
      exercise
    end
    {
      :noreply,
      socket
      |> assign(:order_and_filter_changeset, order_and_filter_changeset(params))
      |> assign(:exercise, exercise)
      |> assign(:page_title, exercise.title)
      |> assign(:is_owner, exercise.author_id == socket.assigns.current_user.id)
    }
  end

  def mount(_params = %{"id" => _id}, _session, socket) do
    {:ok, socket |> assign(:show_delete, Application.get_env(:ace_grader, :dev_routes))}
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
      {%{order_by: "date_desc"}, %{order_by: :string}},
      attrs,
      [:order_by]
    )
  end
end
