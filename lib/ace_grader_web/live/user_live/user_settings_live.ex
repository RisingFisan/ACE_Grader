defmodule AceGraderWeb.UserSettingsLive do
  use AceGraderWeb, :live_view

  alias AceGrader.Accounts

  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-16">
      <div>
        <.header class="mb-6">
        <%= gettext "Change Account Information" %>
          <:actions>
            <.back navigate={~p"/users/#{@current_user.username}"}><%= gettext "Back to account" %></.back>
          </:actions>
        </.header>

        <.simple_form
          for={@info_form}
          id="info_form"
          phx-submit="update_info"
          phx-change="validate_info"
        >
          <.input field={@info_form[:username]} type="text" label={gettext("Username")} required />
          <.input field={@info_form[:display_name]} type="text" label={gettext("Display name")} required />
          <.input field={@info_form[:account_type]} type="radio" label={gettext("Account type")} options={Enum.zip(["student", "teacher"], [gettext("Student"), gettext("Teacher")])} required />
          <:actions>
            <.button phx-disable-with="Changing..."><%= gettext "Change Account Information" %></.button>
          </:actions>
        </.simple_form>
      </div>

      <div>
        <.header  class="mb-6"><%= gettext "Change Email" %></.header>

        <.simple_form
          for={@email_form}
          id="email_form"
          phx-submit="update_email"
          phx-change="validate_email"
        >
          <.input field={@email_form[:email]} type="email" label={gettext("Email")} required />
          <.input
            field={@email_form[:current_password]}
            name="current_password"
            id="current_password_for_email"
            type="password"
            label={gettext("Current password")}
            value={@email_form_current_password}
            required
          />
          <:actions>
            <.button phx-disable-with={gettext("Changing...")}><%= gettext "Change Email" %></.button>
          </:actions>
        </.simple_form>
      </div>

      <div>
        <.header class="mb-6"><%= gettext"Change Password" %></.header>

        <.simple_form
          for={@password_form}
          id="password_form"
          action={~p"/users/log_in?_action=password_updated"}
          method="post"
          phx-change="validate_password"
          phx-submit="update_password"
          phx-trigger-action={@trigger_submit}
        >
          <div> <!-- This div is to prevent the space-y-8 of the form from creating space before the password -->
            <.input id="hidden_user_email" field={@password_form[:email]} type="hidden" value={@current_email} />
            <.input field={@password_form[:password]} type="password" label={gettext("New password")} required />
          </div>
          <.input
            field={@password_form[:password_confirmation]}
            type="password"
            label={gettext("Confirm new password")}
          />
          <.input
            field={@password_form[:current_password]}
            name="current_password"
            type="password"
            label={gettext("Current password")}
            id="current_password_for_password"
            value={@current_password}
            required
          />
          <:actions>
            <.button phx-disable-with={gettext("Changing...")}><%= gettext"Change Password" %></.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    info_changeset = Accounts.change_user_info(user)
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:info_form, to_form(info_changeset))
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)
      |> assign(:page_title, "Settings")

    {:ok, socket}
  end

  def handle_event("validate_info", params, socket) do
    %{"user" => user_params} = params

    info_form =
      socket.assigns.current_user
      |> Accounts.change_user_info(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, info_form: info_form)}
  end

  def handle_event("update_info", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_info(user, user_params) do
      {:ok, user} ->
        {:noreply, socket |> put_flash(:info, "Account information updated successfully!") |> assign(current_user: user, info_form: to_form(Accounts.change_user_info(user)))}
      {:error, changeset} ->
        {:noreply, assign(socket, info_form: to_form(changeset))}
    end
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end
end
