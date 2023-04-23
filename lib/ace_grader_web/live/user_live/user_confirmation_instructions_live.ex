defmodule AceGraderWeb.UserConfirmationInstructionsLive do
  use AceGraderWeb, :live_view

  alias AceGrader.Accounts

  def render(assigns) do
    ~H"""
    <.header><%= gettext "Resend confirmation instructions" %></.header>

    <.simple_form for={@form} id="resend_confirmation_form" phx-submit="send_instructions">
      <.input field={@form[:email]} type="email" label="Email" required />
      <:actions>
        <.button phx-disable-with="Sending..."><%= gettext "Resend confirmation instructions" %></.button>
      </:actions>
    </.simple_form>

    <p>
      <.link href={~p"/users/register"}><%= pgettext "infverb", "Register" %></.link>
      |
      <.link href={~p"/users/log_in"}><%= pgettext "infverb", "Log in" %></.link>
    </p>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_instructions", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &url(~p"/users/confirm/#{&1}")
      )
    end

    info =
      gettext("If your email is in our system and it has not been confirmed yet, you will receive an email with instructions shortly.")

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
