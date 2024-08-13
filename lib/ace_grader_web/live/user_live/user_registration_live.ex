defmodule AceGraderWeb.UserRegistrationLive do
  use AceGraderWeb, :live_view

  alias AceGrader.Accounts
  alias AceGrader.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-lg space-y-4">
      <.header class="text-center">
        <%= gettext "Register for an account" %>
        <:subtitle>
          <%= gettext "Already registered?" %>
          <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
            <%= pgettext "action", "Sign in" %>
          </.link>
          <%= gettext "to your account now." %>
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={@form[:username]} type="text" label={gettext("Username")} placeholder="WA1983" required />
        <.input field={@form[:display_name]} type="text" label={gettext("Display name")} placeholder="Jesse Faden 🔻" required />
        <.input field={@form[:email]} type="email" label={gettext("Email")} required placeholder="hornet@hallownest.com" />
        <.input field={@form[:password]} type="password" label={gettext("Password")} required placeholder="*******" />
        <.input field={@form[:account_type]} type="radio" label={gettext("Account type")} options={Enum.zip(["student", "teacher"], [gettext("Student"), gettext("Teacher")])} required />
        <:actions>
          <.button phx-disable-with={gettext("Creating account...")} class="w-full"><%= gettext "Create an account" %></.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{}, %{account_type: :student})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
