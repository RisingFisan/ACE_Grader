defmodule AceGraderWeb.ClassLive.Show do
  use AceGraderWeb, :live_view

  alias AceGrader.Classes

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:class, Classes.get_class!(id))}
  end

  defp page_title(:show), do: "Show Class"
  defp page_title(:edit), do: "Edit Class"
end
