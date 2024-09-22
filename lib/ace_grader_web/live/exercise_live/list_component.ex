defmodule AceGraderWeb.ExerciseLive.ListComponent do
  use AceGraderWeb, :live_component

  alias AceGrader.Exercises

  def mount(socket) do
    {:ok, socket |> assign(order_and_filter: to_form(%{"order_by" => "date_desc"}))}
  end

  def update(%{type: :class, class: class}, socket) do
    exercises = get_exercises({:class, class}, socket.assigns.order_and_filter[:order_by].value)
    {:ok, socket |> assign(class: class, exercises: exercises)}
  end

  def update(%{type: :user, user: user, current_user?: self}, socket) do
    exercises = get_exercises({:user, user, self}, socket.assigns.order_and_filter[:order_by].value)
    {:ok, socket |> assign(user: user, current_user?: self, exercises: exercises)}
  end

  def update(%{type: :public, user: user}, socket) do
    exercises = get_exercises({:public, user}, socket.assigns.order_and_filter[:order_by].value)
    {:ok, socket |> assign(user: user, exercises: exercises)}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.form for={@order_and_filter} phx-change="order_and_filter" phx-target={@myself}>
        <% options = [{gettext("Title"), "title_asc"}, {gettext("Title (Desc)"), "title_desc"},
                  {gettext("Date"), "date_asc"}, {gettext("Date (Desc)"), "date_desc"}] %>
        <div class="space-y-2">
          <div class="flex justify-end items-center gap-4">
            <div class="flex items-center gap-2">
              <p><%= gettext("Sort by") %></p>
              <.input field={@order_and_filter[:order_by]} type="select" options={options} phx-debounce="500"/>
            </div>
            <div class="cursor-pointer p-3 rounded-full" phx-click={JS.toggle(to: "#filter-options") |> JS.toggle_class("bg-zinc-200 dark:bg-zinc-800")}>
              <.icon name="hero-funnel" class="w-6 h-6"/>
            </div>
          </div>
          <div id="filter-options" class="hidden bg-zinc-200 dark:bg-zinc-800 select-none px-3 py-1 rounded-md">
            <label><%= gettext "Language(s)" %></label>
            <.inputs_for field={@order_and_filter[:languages]} id="filter_languages" as={:languages} :let={fl}>
              <%= for language <- AceGrader.Exercises.Languages.supported_languages do %>
                <.input field={fl[language]} type="checkbox" label={String.capitalize(Atom.to_string(language))} phx-debounce="500" />
              <% end %>
            </.inputs_for>
            <%!-- <.input field={@order_and_filter[:unique]} type="checkbox" label={gettext "Show only 1 submission per user."}/> --%>
          </div>
        </div>
      </.form>
      <.link :for={exercise <- @exercises} navigate={~p"/exercises/#{exercise}"} class="w-full h-24 bg-zinc-100 dark:bg-zinc-700 hover:bg-zinc-200 hover:dark:bg-zinc-600 rounded-lg px-4 py-2 cursor-pointer
        grid grid-cols-[1fr_max-content] gap-4">
        <div class="space-y-2">
          <div class="flex items-center gap-4">
            <h3 class="text-2xl font-bold"><%= exercise.title %></h3>
            <div class="flex gap-2 items-end">
              <.icon name="hero-eye-slash" :if={exercise.visibility == :private} class="w-6 h-6 hoverToShow"/>
              <p class="showOnHover"><%= gettext "Private" %></p>
              <.icon name="hero-academic-cap" :if={exercise.visibility == :class} class="w-6 h-6 hoverToShow"/>
              <p class="showOnHover"><%= gettext "From one of your classes" %></p>
            </div>
          </div>
          <div class="text-sm line-clamp-2">
            <p class="whitespace-pre-line"><%= exercise.description %></p>
          </div>
        </div>
        <div class="justify-self-end text-right">
          <p><%= exercise.inserted_at |> NaiveDateTime.to_date |> Date.to_string %></p>
          <p class="text-zinc-600 dark:text-zinc-400 font-light"><%= exercise.language |> Atom.to_string() |> String.capitalize() %></p>
        </div>
      </.link>
    </div>
    """
  end

  def handle_event("order_and_filter", %{"order_by" => order_by, "languages" => languages}, socket) do
    IO.inspect(languages)
    category = cond do
      socket.assigns[:current_user?] -> {:user, socket.assigns.user, socket.assigns.current_user?}
      socket.assigns[:class] -> {:class, socket.assigns.class}
      true -> {:public, socket.assigns.user}
    end
    filter_languages = AceGrader.Exercises.Languages.supported_languages
      |> Enum.map(& &1 |> Atom.to_string())
      |> Enum.filter(fn lang -> Map.get(languages, lang, "false") == "true" end)
    {:noreply, socket |> assign(
      exercises: get_exercises(category, order_by, filter_languages),
      order_and_filter: to_form(%{"order_by" => order_by, "languages" => languages})
    )}
  end

  defp get_exercises(category, order_by, languages \\ []) do
    IO.inspect(category)
    case category do
      {:public, user} -> Exercises.list_public_exercises(order_by: order_by, user_id: (if user, do: user.id, else: nil), languages: languages)
      {:user, user, self} -> Exercises.list_exercises_by_user(user.id, not self, order_by: order_by, languages: languages)
      {:class, class} -> Exercises.list_exercises_by_class(class.id, order_by: order_by, languages: languages)
    end
  end

end
