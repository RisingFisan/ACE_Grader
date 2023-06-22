defmodule AceGraderWeb.ClassLive.FormComponent do
  use AceGraderWeb, :live_component

  alias AceGrader.Classes

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="class-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Class</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{class: class} = assigns, socket) do
    changeset = Classes.change_class(class)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"class" => class_params}, socket) do
    changeset =
      socket.assigns.class
      |> Classes.change_class(class_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"class" => class_params}, socket) do
    save_class(socket, socket.assigns.action, class_params)
  end

  defp save_class(socket, :edit, class_params) do
    case Classes.update_class(socket.assigns.class, class_params) do
      {:ok, class} ->
        notify_parent({:saved, class})

        {:noreply,
         socket
         |> put_flash(:info, "Class updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_class(socket, :new, class_params) do
    class_params = Map.put(class_params, "creator_id", socket.assigns.current_user.id)
    case Classes.create_class(class_params) do
      {:ok, class} ->
        notify_parent({:saved, class})

        {:noreply,
         socket
         |> put_flash(:info, "Class created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
