defmodule AceGraderWeb.ExerciseLive.Index do
  use AceGraderWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-8">
      <.header>
        <%= gettext "Exercises" %>
        <:subtitle :if={@current_user}>
          <%= gettext "Every exercise that is either public, created by you, or from one of your classes." %>
        </:subtitle>
        <:actions>
          <.link navigate={~p"/exercises/new"}>
            <div class="fixed bottom-6 left-1/2 -translate-x-1/2 select-none">
              <.button :if={@current_user && @current_user.account_type != :student} kind={:teacher} class="flex items-center gap-2">
                <.icon name="hero-plus" class="w-5 h-5" />
                <%= gettext "New Exercise" %>
              </.button>
            </div>
          </.link>
        </:actions>
      </.header>

      <.live_component
        module={AceGraderWeb.ExerciseLive.ListComponent}
        id="exercise_list"
        type={:public}
        user={@current_user}
      />
    </div>
    """
  end
end
