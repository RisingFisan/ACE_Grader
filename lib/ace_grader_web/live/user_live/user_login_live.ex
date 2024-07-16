defmodule AceGraderWeb.UserLoginLive do
  use AceGraderWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-lg space-y-4">
      <.header class="text-center">
        <%= gettext "Sign in to account" %>
        <:subtitle>
          <%= gettext "Don't have an account?" %>
          <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
            <%= pgettext "action", "Sign up" %>
          </.link>
          <%= gettext "for an account now." %>
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />
        <.link href={~p"/users/reset_password"} class="text-sm font-semibold text-right">
          <p class="mt-2"><%= gettext "Forgot your password?" %></p>
        </.link>
        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label={gettext "Keep me logged in"} />
        </:actions>
        <:actions>
          <.button phx-disable-with="Signing in..." class="w-full">
            <%= gettext "Sign in" %><span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
