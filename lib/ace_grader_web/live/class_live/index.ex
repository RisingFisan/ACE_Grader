defmodule AceGraderWeb.ClassLive.Index do
  use AceGraderWeb, :live_view

  alias AceGrader.Classes
  alias AceGrader.Classes.Class

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :classes, Classes.list_classes())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit class")
    |> assign(:class, Classes.get_class!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New class")
    |> assign(:class, %Class{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing classes")
    |> assign(:class, nil)
  end

  @impl true
  def handle_info({AceGraderWeb.ClassLive.FormComponent, {:saved, class}}, socket) do
    {:noreply, stream_insert(socket, :classes, class)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    class = Classes.get_class!(id)
    {:ok, _} = Classes.delete_class(class)

    {:noreply, stream_delete(socket, :classes, class)}
  end
end
