defmodule AceGraderWeb.HomeLive do
  use AceGraderWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="h-64 bg-violet-700">
      <div class="flex flex-col items-center justify-center h-full gap-3">
        <img src={"/images/ACEGrader_white.svg"} alt="ACE Grader" class="w-48 md:w-64"/>
        <p class="font-light tracking-wider text-xl text-zinc-200 text-center px-16"><%= gettext "Automatic Code Evaluator and Grader" %></p>
      </div>
    </div>
    <div class="px-4 py-6 sm:py-12 md:px-8 lg:px-12 xl:px-16 flex flex-col items-center md:items-start gap-6">
      <%= if @current_user do %>
        <div class="flex flex-col items-center md:items-start gap-3">
          <h2 class="text-2xl md:text-4xl font-bold"><%= gettext("Welcome back, %{name}!", name: @current_user.display_name) %></h2>
          <.link href={~p"/users/#{@current_user}"}>
            <.button>
              <%= gettext "Go to my account" %>
            </.button>
          </.link>
        </div>
      <% else %>
        <.link :if={!@current_user} href={~p"/users/log_in"}>
          <.button>
            <%= gettext "Log in" %>
          </.button>
        </.link>
      <% end %>
      <.link href={~p"/exercises"}>
        <.button>
          <%= gettext "Go to Exercises" %>
        </.button>
      </.link>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket, layout: {AceGraderWeb.Layouts, :home}}
  end
end
