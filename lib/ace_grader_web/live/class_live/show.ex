defmodule AceGraderWeb.ClassLive.Show do
  use AceGraderWeb, :live_view

  alias AceGrader.Classes

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    class = Classes.get_class!(id)
    case socket.assigns.live_action do
      :edit ->
        if class.creator_id != socket.assigns.current_user.id do
          {:noreply,
          socket
          |> put_flash(:error, "You do not have permission to edit this class.")
          |> redirect(to: ~p"/classes/#{class}")}
        else
          {:noreply,
           socket
           |> assign(:page_title, page_title(socket.assigns.live_action))
           |> assign(:class, class)}
        end
      :show ->
        {:noreply,
         socket
         |> assign(:page_title, page_title(socket.assigns.live_action))
         |> assign(:class, class)}
    end
  end

  defp page_title(:show), do: "Show Class"
  defp page_title(:edit), do: "Edit Class"
end
