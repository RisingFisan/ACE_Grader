defmodule AceGraderWeb.ExerciseLive.Show do
  use AceGraderWeb, :live_view
  alias AceGrader.Exercises

  import Ecto.Changeset

  def handle_params(params = %{"id" => id}, _url, socket) do
    exercise = cond do
      socket.assigns.current_user == nil -> Exercises.get_exercise!(id, false)
      socket.assigns.current_user.account_type == :student ->
        Exercises.get_exercise!(id, true, params)
        |> Map.update!(:submissions, fn submissions ->
          Enum.filter(submissions, fn submission ->
            submission.author_id == socket.assigns.current_user.id
          end)
        end)
      true -> Exercises.get_exercise!(id, true, params)
    end
    {
      :noreply,
      socket
      |> assign(:order_and_filter_changeset, order_and_filter_changeset(params))
      |> assign(:exercise, exercise)
      |> assign(:page_title, exercise.title)
      |> assign(:is_owner, socket.assigns.current_user != nil and exercise.author_id == socket.assigns.current_user.id)
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
