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
    case socket.assigns.live_action do
      :new -> if socket.assigns.current_user.account_type != :student do
        {:noreply, apply_action(socket, socket.assigns.live_action, params)}
      else
        {:noreply, socket |> put_flash(:error, "You do not have permission to create a class.") |> push_patch(to: "/classes")}
      end
      _ -> {:noreply, apply_action(socket, socket.assigns.live_action, params)}
    end
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    class = Classes.get_class!(id)
    if class.creator_id != socket.assigns.current_user.id do
      socket
      |> put_flash(:error, "You do not have permission to edit this class.")
      |> push_patch(to: "/classes")
    else
      socket
      |> assign(:page_title, "Edit class")
      |> assign(:class, class)
    end
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
    if class.creator_id != socket.assigns.current_user.id do
      {:noreply,
       socket
       |> put_flash(:error, "You do not have permission to delete this class.")
       |> push_patch(to: "/classes")}
    else
      {:ok, _} = Classes.delete_class(class)

      {:noreply, stream_delete(socket, :classes, class)}
    end
  end
end
