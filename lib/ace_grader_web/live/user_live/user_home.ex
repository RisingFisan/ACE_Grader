defmodule AceGraderWeb.UserLive.UserHome do
  use AceGraderWeb, :live_view

  alias AceGrader.Accounts
  alias AceGrader.Exercises
  alias AceGrader.Submissions

  def mount(%{"username" => username}, _session, socket) do
    user = Accounts.get_user_by_username!(username)
    socket = socket |> assign(submissions: false)
    if socket.assigns.current_user == nil do
      {:ok, socket |> assign(user: user)}
    else
      exercises = if user.account_type == :teacher, do: Exercises.list_exercises_by_user(user.id, user.id != socket.assigns.current_user.id), else: nil
      socket = socket |> assign(user: user, exercises: exercises)
      if socket.assigns.current_user.account_type == :teacher || socket.assigns.current_user.id == user.id do
        submissions = Submissions.list_submissions_by_user(user.id)
        {:ok, socket |> assign(:submissions, true) |> stream(:submissions, submissions)}
      else
        {:ok, socket}
      end
    end
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-12">
      <div class="flex flex-col sm:flex-row gap-6 justify-between items-start">
        <div class="flex gap-4">
          <div class="h-36 w-36 border-4 border-black dark:border-white p-6">
            <.icon name="hero-user" class="w-full h-full"/>
          </div>
          <div class="flex flex-col justify-between">
            <div>
              <p class="text-4xl font-bold"><%= @user.display_name %></p>
              <p class="text-xl font-light"><%= "(@#{@user.username})" %></p>
            </div>
            <p class="text-xl" :if={@user.account_type == :student}><%= gettext("Student") %></p>
            <p class="text-xl" :if={@user.account_type == :teacher}><%= gettext("Teacher") %></p>
            <p class="text-xl" :if={@user.account_type == :admin}><%= gettext("Administrator") %></p>
          </div>
        </div>
        <.link
          :if={@current_user && @current_user.id == @user.id}
          navigate={~p"/users/settings"}
          class="text-lg font-semibold leading-6 text-zinc-900 dark:text-zinc-100 hover:text-zinc-700 dark:hover:text-zinc-100 outline-zinc-900 dark:outline-zinc-200 outline rounded-full px-4 py-2 hover:bg-zinc-200 dark:hover:bg-zinc-700 duration-200 flex items-center gap-2 self-end sm:self-start"
          >
          <.icon name="hero-pencil" class="w-5 h-5 stroke-current inline" />
          <%= gettext("Edit account") %>
        </.link>
      </div>

      <div :if={@user.account_type == :teacher} class="space-y-4">
        <h2 class="text-3xl font-bold"><%= gettext("Exercises created by") <> " " <> @user.display_name %></h2>
        <.live_component
        module={AceGraderWeb.ExerciseLive.ListComponent}
        id="exercise_list"
        type={:user}
        user={@user}
        current_user?={@current_user != nil and @user.id == @current_user.id}
        />
      </div>

      <div :if={@submissions && @streams.submissions != nil} class="space-y-4">
        <%= if @current_user.id == @user.id do %>
          <h2 class="text-3xl font-bold"><%= gettext "My submissions" %></h2>
        <% else %>
          <h2 class="text-3xl font-bold"><%= gettext("%{name}'s submissions", name: @user.display_name) %></h2>
        <% end %>
        <.table id="submissions-table" rows={@streams.submissions} row_click={&JS.navigate(~p"/exercises/#{elem(&1, 1).exercise}/submissions/#{elem(&1, 1)}")}>
          <:col :let={{_sub_id, submission}} label={gettext "Exercise name"}><%= submission.exercise.title %></:col>
          <:col :let={{_sub_id, submission}} label={gettext "Total grade"}><%= submission.total_grade %>%</:col>
          <:col :let={{_sub_id, submission}} label={gettext "Date"}><time x-text={"$store.formatDateTime('#{submission.inserted_at}')"}></time></:col>
        </.table>
      </div>
    </div>
    """
  end
end
