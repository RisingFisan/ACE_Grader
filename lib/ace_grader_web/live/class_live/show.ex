defmodule AceGraderWeb.ClassLive.Show do
  use AceGraderWeb, :live_view

  alias AceGrader.Classes
  alias AceGrader.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    class = Classes.get_class!(id)
    enrolled = socket.assigns.current_user.id in [ class.creator_id | Enum.map(class.members, & &1.id) ]
    socket = assign(socket,
      class: class,
      join_url: "#{socket.endpoint.url}/classes/#{class.id}/join",
      enrolled: enrolled,
      page_title: page_title(socket.assigns.live_action, class))
    case socket.assigns.live_action do
      :edit ->
        if class.creator_id != socket.assigns.current_user.id do
          {:noreply,
          socket
          |> put_flash(:error, "You do not have permission to edit this class.")
          |> push_navigate(to: ~p"/classes/#{class}")}
        else
          {:noreply, socket}
        end
      :show ->
        {:noreply, socket}
      :join ->
        if enrolled do
          {:noreply, socket
            |> put_flash(:warning, "You're already in this class.")
            |> push_patch(to: ~p"/classes/#{class}")}
        else
          {:noreply, socket}
        end
    end
  end

  @impl true
  def handle_event("join-class", _, socket) do
    class = socket.assigns.class
    user = socket.assigns.current_user
    case Accounts.add_to_class(user, class) do
      {:ok, _user} -> {:noreply, socket
        |> put_flash(:info, "Successfully joined class!")
        |> push_patch(to: ~p"/classes/#{class}")
      }
      {:error, _changeset} -> {:noreply, socket
        |> put_flash(:error, "Error while joining class.")
        |> redirect(to: ~p"/classes/#{class}")
      }
    end
  end

  def handle_event("leave-class", _, socket) do
    class = socket.assigns.class
    user = socket.assigns.current_user
    case Accounts.remove_from_class(user, class) do
      {:ok, _user} -> {:noreply, socket
        |> put_flash(:info, "Successfully left class!")
        |> push_patch(to: ~p"/classes/#{class}")
      }
      {:error, _changeset} -> {:noreply, socket
        |> put_flash(:error, "Error while leaving class.")
        |> redirect(to: ~p"/classes/#{class}")
      }
    end
  end

  defp page_title(:show, class), do: "Class #{class.name}"
  defp page_title(:edit, class), do: "Editing class #{class.name}"
  defp page_title(:join, class), do: "Joining class #{class.name}"
end
