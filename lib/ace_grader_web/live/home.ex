defmodule AceGraderWeb.HomeLive do
  use AceGraderWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="h-64 bg-violet-700">
      <div class="flex flex-col items-center justify-center h-full">
        <h1 class="text-[6em] text-white font-bold">ACE Grader</h1>
        <p class="font-light tracking-wider text-xl text-zinc-200">Automatic Code Evaluator and Grader</p>
      </div>
    </div>
    <div class="px-4 py-6 sm:py-12 sm:px-6 lg:px-8 xl:px-28">
      <.link href={~p"/exercises"}>
        <.button class="mt-8">
          Go to Exercises
        </.button>
      </.link>
      <.link :if={!@current_user} href={~p"/users/log_in"}>
        <.button class="mt-8">
          Log in
        </.button>
      </.link>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket, layout: {AceGraderWeb.Layouts, "home.html"}}
  end
end
