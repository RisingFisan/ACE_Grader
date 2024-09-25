defmodule AceGraderWeb.MyComponents do

  use Phoenix.Component
  use Phoenix.VerifiedRoutes,
    endpoint: AceGraderWeb.Endpoint,
    router: AceGraderWeb.Router

  import AceGraderWeb.Gettext
  import Phoenix.HTML
  import AceGraderWeb.CoreComponents

  attr :tests, :list
  attr :error, :boolean, default: :false
  attr :editor, :boolean, default: false

  def test_results(assigns) do
    ~H"""
    <div :if={length(@tests) > 0} class="space-y-2 md:space-y-4 bg-zinc-300 dark:bg-zinc-800 rounded-[24px] md:rounded-[32px] px-5 md:px-8 py-2 md:py-4">
      <h2 class="text-xl md:text-2xl font-bold"><%= gettext "Tests" %></h2>
      <div class="space-y-4">
        <div :for={{test, i} <- @tests |> Enum.with_index(1)}
          class={["grid grid-cols-1 md:grid-cols-[92px_1fr_128px] items-center text-lg rounded-xl border-2 border-zinc-400 dark:border-zinc-600",
            (test.status == :success && "bg-green-200 dark:bg-green-800"),
            ((test.status in [:failed, :error] or @error) && "bg-red-200 dark:bg-red-900"),
            (test.status == :timeout && "bg-orange-100 dark:bg-orange-900"),
            (test.status == :pending && "bg-zinc-100 dark:bg-zinc-700"),
          ]}>
          <div class="h-full w-full font-light bg-zinc-200 dark:bg-zinc-500 flex flex-col items-center justify-center rounded-l-lg py-1">
            <h3 class="text-xl"><%= "#{pgettext("noun", "Test")} #{i}" %></h3>
            <p :if={!@editor}><%= "(#{test.grade}%)" %></p>
          </div>
          <div class="pl-4 py-2 grid grid-cols-[min-content_1fr] md:grid-cols-[150px_1fr] gap-y-1 gap-x-4 items-start border-l border-zinc-400 dark:border-zinc-700">
            <%= if test.description do %>
              <p><%= gettext "Description" %></p>
              <p><%= test.description %></p>
            <% else %>
              <p><%= gettext "Input" %></p>
              <pre class="whitespace-pre-wrap"><%= test.input %></pre>
            <% end %>

            <p><%= gettext "Expected output" %></p>
            <pre class="whitespace-pre-wrap"><%= test.expected_output %></pre>

            <%= if test.status != :error do %>
              <p><%= gettext "Actual output" %></p>
              <%= if test.actual_output != nil do %>
                <pre class="whitespace-pre-wrap"><%= test.actual_output %></pre>
              <% else %>
                <%= if test.status == :pending do %>
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" class="w-4 self-center fill-blue-500 animate-spin"><!--! Font Awesome Pro 6.3.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2023 Fonticons, Inc. -->
                    <path d="M304 48c0-26.5-21.5-48-48-48s-48 21.5-48 48s21.5 48 48 48s48-21.5 48-48zm0 416c0-26.5-21.5-48-48-48s-48 21.5-48 48s21.5 48 48 48s48-21.5 48-48zM48 304c26.5 0 48-21.5 48-48s-21.5-48-48-48s-48 21.5-48 48s21.5 48 48 48zm464-48c0-26.5-21.5-48-48-48s-48 21.5-48 48s21.5 48 48 48s48-21.5 48-48zM142.9 437c18.7-18.7 18.7-49.1 0-67.9s-49.1-18.7-67.9 0s-18.7 49.1 0 67.9s49.1 18.7 67.9 0zm0-294.2c18.7-18.7 18.7-49.1 0-67.9S93.7 56.2 75 75s-18.7 49.1 0 67.9s49.1 18.7 67.9 0zM369.1 437c18.7 18.7 49.1 18.7 67.9 0s18.7-49.1 0-67.9s-49.1-18.7-67.9 0s-18.7 49.1 0 67.9z"/>
                  </svg>
                <% end %>
              <% end %>
            <% else %>
              <p><%= gettext "Error message" %></p>
              <pre class="whitespace-pre-wrap"><%= test.actual_output %></pre>
            <% end %>
          </div>
          <div class="justify-self-center md:justify-self-end md:pr-4">
            <AceGraderWeb.CoreComponents.icon name="hero-check_circle" :if={test.status == :success} class="w-12 h-12 text-green-600" />
            <div :if={test.status == :error} class="flex items-center text-red-600 dark:text-red-400 tracking-wider gap-2 text-xl">
              <p><%= gettext "Error" %></p>
              <AceGraderWeb.CoreComponents.icon name="hero-x-circle" class="w-12 h-12"/>
            </div>
            <div :if={test.status == :failed} class="flex items-center text-red-600 dark:text-red-400 tracking-wider gap-2 text-xl">
              <p><%= gettext "Failed" %></p>
              <AceGraderWeb.CoreComponents.icon name="hero-x-circle" class="w-12 h-12"/>
            </div>
            <div :if={test.status == :timeout} class="flex items-center text-orange-600 dark:text-orange-400 tracking-wider gap-2 text-xl">
              <p><%= gettext "Timeout" %></p>
              <AceGraderWeb.CoreComponents.icon name="hero-exclamation_circle" class="w-12 h-12"/>
            </div>
            <AceGraderWeb.CoreComponents.icon name="hero-clock" :if={test.status == :pending} class="w-12 h-12" />
          </div>
        </div>
      </div>
    </div>
    """
  end


  attr :parameters, :list
  attr :error, :boolean, default: :false
  attr :editor, :boolean, default: false

  def parameter_results(assigns) do
    ~H"""
    <div :if={length(@parameters) > 0} class="space-y-2 md:space-y-4 bg-zinc-300 dark:bg-zinc-800 rounded-[24px] md:rounded-[32px] px-5 md:px-8 py-2 md:py-4">
      <h2 class="text-xl md:text-2xl font-bold"><%= gettext "Parameters" %></h2>
      <div class="space-y-4">
        <div :for={parameter <- @parameters}
          class={["grid grid-cols-1 md:grid-cols-[148px_1fr_128px] items-center text-lg rounded-xl border-2 border-zinc-400 dark:border-zinc-600",
            (parameter.status == :success && "bg-green-200 dark:bg-green-800"),
            ((parameter.status in [:failed, :error] or @error) && "bg-red-200 dark:bg-red-900"),
            (parameter.status == :timeout && "bg-orange-100 dark:bg-orange-900"),
            (parameter.status == :pending && "bg-zinc-100 dark:bg-zinc-700"),
          ]}>
          <div class="h-full w-full font-light bg-zinc-200 dark:bg-zinc-500 flex flex-col items-center justify-center rounded-l-lg py-1">
            <h3 class="text-xl text-center"><%= "#{gettext("Parameter")} #{parameter.position + 1}" %></h3>
            <%= if !@editor do %>
              <p :if={parameter.type == :optional}><%= "(0%)" %></p>
              <p :if={parameter.type == :graded}><%= "(#{parameter.grade}%)" %></p>
              <p :if={parameter.type == :mandatory}><%= "(100%)" %></p>
            <% end %>
          </div>
          <div class="pl-4 py-2 grid grid-cols-[min-content_1fr] md:grid-cols-[96px_1fr] gap-y-1 gap-x-4 items-start border-l border-zinc-400 dark:border-zinc-700">
            <p><%= gettext "Check if" %></p>
            <p><%= (AceGraderWeb.Utils.get_keys(parameter.negative, parameter.value) |> Map.get(parameter.key)) <> "." %></p>
          </div>
          <div class="justify-self-center md:justify-self-end md:pr-4">
            <.icon name="hero-check_circle" :if={parameter.status == :success} class="w-8 h-8 text-green-600" />
            <div :if={parameter.status == :error} class="flex items-center text-red-600 dark:text-red-400 tracking-wider gap-2 text-xl">
              <p><%= gettext "Error" %></p>
              <.icon name="hero-x-circle" class="w-8 h-8"/>
            </div>
            <div :if={parameter.status == :failed} class="flex items-center text-red-600 dark:text-red-400 tracking-wider gap-2 text-xl">
              <p><%= gettext "Failed" %></p>
              <.icon name="hero-x-circle" class="w-8 h-8"/>
            </div>
            <div :if={parameter.status == :timeout} class="flex items-center text-orange-600 dark:text-orange-400 tracking-wider gap-2 text-xl">
              <p><%= gettext "Timeout" %></p>
              <.icon name="hero-exclamation-circle" class="w-8 h-8"/>
            </div>
            <.icon name="hero-clock" :if={parameter.status == :pending} class="w-8 h-8" />
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :message, :string
  attr :status, :atom, [:success, :error, :pending]

  def compilation_results(assigns) do
    ~H"""
    <div class="bg-zinc-300 dark:bg-zinc-800 rounded-[24px] md:rounded-[32px] px-5 md:px-8 py-2 md:py-4 text-xl md:text-2xl space-y-2 md:space-y-4"
      x-data={"{ compilationMessage: false }"}>
      <div class="flex justify-between" x-on:click="compilationMessage = !compilationMessage">
        <p class="font-bold"><%= gettext "Compilation" %></p>
        <div>
          <%= if @status == :success and (@message == nil or @message == "") do %>
            <div class="flex items-center text-green-600 gap-2 font-bold">
              <.icon name="hero-check" class="w-8 h-8"/><p><%= gettext "Successful" %></p>
            </div>
          <% else %>
            <%= case @status do %>
              <% :success -> %>
                <div class="flex items-center text-yellow-600 gap-2 font-bold">
                  <.icon name="hero-exclamation-triangle" class="w-6 h-6 md:w-8 md:h-8"/>
                  <p><%= gettext "Warning" %></p>
                  <.icon name="hero-chevron-down" class="w-4 md:w-8 h-4 md:h-6 self-end text-gray-500 animate-bounce"/>
                </div>
              <% :error -> %>
                <div class="flex items-center text-red-600 gap-2 font-bold">
                  <.icon name="hero-exclamation-circle" class="w-6 h-6 md:w-8 md:h-8"/>
                  <p><%= gettext "Error" %></p>
                  <.icon name="hero-chevron-down" class="w-4 md:w-8 h-4 md:h-6 self-end text-gray-500 animate-bounce"/>
                </div>
              <% :pending -> %>
                <div class="flex items center text-gray-600 gap-2 font-bold">
                  <.icon name="hero-clock" class="w-6 h-6 md:w-8 md:h-8"/>
                  <p><%= gettext "Pending" %></p>
                </div>
            <% end %>
          <% end %>
        </div>
      </div>
      <pre :if={@message} x-show="compilationMessage" id="compilation_message" class="break-all whitespace-pre-wrap text-lg" x-collapse><%= String.trim(@message) %></pre>
    </div>
    """
  end

  attr :right, :boolean, default: false

  slot :inner_block, required: true

  def help(assigns) do
    ~H"""
    <div x-data="{ show: false }" class="lg:relative">
      <div x-on:mouseover=" show = true " x-on:mouseout="show = false " >
        <.icon name="hero-question-mark-circle" class="h-6 w-6 hover:text-zinc-700 hover:dark:text-zinc-300 duration-200" />
      </div>
      <div x-show="show"
        x-transition:enter="transition-opacity duration-300"
        x-transition:enter-start="opacity-0"
        x-transition:enter-end="opacity-100"
        x-transition:leave="transition-opacity duration-200"
        x-transition:leave-start="opacity-100"
        x-transition:leave-end="opacity-0"
        class={"absolute left-2 right-2 mt-2 lg:left-[auto] lg:w-max #{if @right, do: 'lg:right-0', else: 'lg:right-[auto]'} bg-zinc-300 dark:bg-zinc-600 px-4 py-2 rounded-xl select-none z-50"}>
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  attr :id, :string
  attr :type, :string, values: ~w(normal read-only markdown), default: "normal"
  attr :language, :string
  attr :field, Phoenix.HTML.FormField
  attr :initial_value, :string

  def editor(%{type: "read-only"} = assigns) do
    ~H"""
    <div id={@id} phx-update="ignore">
      <div
        class="space-y-4"
        x-data="{ editor: null, expand: false }"
        x-init={"

          language_file = (lang) => {
            switch(lang) {
              case 'c': return 'c_cpp';
              default: return lang;
            }
          }

          editor = $store.ace.edit($refs.editor, {
            maxLines: 20,
            readOnly: true,
            wrap: 'free',
            highlightActiveLine: false,
            highlightGutterLine: false
          });
          editor.renderer.$cursorLayer.element.style.display = 'none'
          if ($store.theme == 'Light') {
            editor.setTheme('ace/theme/eclipse');
          } else {
            editor.setTheme('ace/theme/dracula');
          }
          editor.session.setMode(`ace/mode/${language_file('#{@language}')}`);
          if($refs.editor_loading) {
            $refs.editor_loading.remove();
          }
        "}
      >
        <div class="editor-container">
          <div x-ref="editor_loading" class="editor-loading">
            <p><%= gettext "Loading editor" %></p>
            <.icon name="hero-cog-6-tooth" class="animate-[reverse-spin_3s_linear_infinite]"/>
          </div>
          <div x-ref="editor" class="editor"><%= @initial_value %></div>
        </div>
        <div class="flex justify-end gap-2">
          <button
            type="button"
            class="border border-zinc-500 rounded-xl p-1"
            x-bind:class=" expand ? 'bg-zinc-200 dark:bg-zinc-500' : ''"
            @click="expand ? editor.setOptions({minLines: 0, maxLines: 20}) : editor.setOptions({minLines: 12, maxLines: 100}) ; expand = ! expand ">
            <span x-show="!expand"><.icon name="hero-arrows-pointing-out" class="w-6"/></span>
            <span x-show="expand"><.icon name="hero-arrows-pointing-in" class="w-6"/></span>
          </button>
        </div>
      </div>
    </div>
    """
  end

  def editor(assigns) do
    ~H"""
    <div id={@id} phx-update="ignore">
      <div
        class="space-y-4"
        x-data="{ editor: null, expand: false }"
        x-init={"

          language_file = (lang) => {
            switch(lang) {
              case 'c': return 'c_cpp';
              default: return lang;
            }
          }

          editor = $store.ace.edit($refs.editor, {
            maxLines: 20,
            wrap: 'free',
          });
          if ($store.theme == 'Light') {
            editor.setTheme('ace/theme/eclipse');
          } else {
            editor.setTheme('ace/theme/dracula');
          }
          editor.session.setMode(`ace/mode/${language_file('#{@language}')}`);
          $refs.editor_input.value = editor.getValue();
          if($refs.editor_loading) {
            $refs.editor_loading.remove();
          }
          editor.session.on('change', function(delta) {
            $refs.editor_input.value = editor.getValue();
            $refs.editor_input.dispatchEvent(new Event('input', { bubbles: true }));
          });
          window.addEventListener('phx:change_language', (e) => {
            let v = e.detail['#{@field.field}'];
            if (v) {
              editor.setValue(v, -1);
              editor.session.setMode(`ace/mode/${language_file(e.detail['language'])}`);
            }
          })
        "}
      >
        <div class="editor-container">
          <div x-ref="editor_loading" class="editor-loading">
            <p><%= gettext "Loading editor" %></p>
            <.icon name="hero-cog-6-tooth" class="animate-[reverse-spin_3s_linear_infinite]"/>
          </div>
          <input type="hidden" x-ref="editor_input" name={@field.name} value={@field.value}/>
          <div x-ref="editor" class="editor"><%= @initial_value %></div>
        </div>
        <div class="flex justify-end gap-2">
          <button
            type="button"
            class="border border-zinc-500 rounded-xl p-1"
            x-bind:class=" expand ? 'bg-zinc-200 dark:bg-zinc-500' : ''"
            @click="expand ? editor.setOptions({minLines: 0, maxLines: 20}) : editor.setOptions({minLines: 12, maxLines: 100}) ; expand = ! expand ">
            <span x-show="!expand"><.icon name="hero-arrows-pointing-out" class="w-6"/></span>
            <span x-show="expand"><.icon name="hero-arrows-pointing-in" class="w-6"/></span>
          </button>
        </div>
      </div>
    </div>
    """
  end

  attr :content, :string, default: ""

  def markdown_text(assigns) do
    ~H"""
    <div id="markdown-text" class="space-y-3 md-text leading-relaxed" phx-hook="Markdown"><%= @content |> Earmark.as_html!(code_class_prefix: "language-") |> raw %></div>
    """
  end

  attr :class, :string, default: nil

  def ace_grader_logo(assigns) do
    ~H"""
    <svg
      width="36px"
      height="36px"
      version="1.1"
      viewBox="0 0 600 600"
      xmlns="http://www.w3.org/2000/svg"
      xmlns:xlink="http://www.w3.org/1999/xlink"
      class={["fill-violet-800", @class]}
    >
      <defs>
        <symbol id="v" overflow="visible">
        <path d="m18.766-1.125c-0.96875 0.5-1.9805 0.875-3.0312 1.125-1.043 0.25781-2.1367 0.39062-3.2812 0.39062-3.3984 0-6.0898-0.94531-8.0781-2.8438-1.9922-1.9062-2.9844-4.4844-2.9844-7.7344 0-3.2578 0.99219-5.8359 2.9844-7.7344 1.9883-1.9062 4.6797-2.8594 8.0781-2.8594 1.1445 0 2.2383 0.13281 3.2812 0.39062 1.0508 0.25 2.0625 0.625 3.0312 1.125v4.2188c-0.98047-0.65625-1.9453-1.1406-2.8906-1.4531-0.94922-0.3125-1.9492-0.46875-3-0.46875-1.875 0-3.3516 0.60547-4.4219 1.8125-1.0742 1.1992-1.6094 2.8555-1.6094 4.9688 0 2.1055 0.53516 3.7617 1.6094 4.9688 1.0703 1.1992 2.5469 1.7969 4.4219 1.7969 1.0508 0 2.0508-0.14844 3-0.45312 0.94531-0.3125 1.9102-0.80078 2.8906-1.4688z"/>
        </symbol>
        <symbol id="d" overflow="visible">
        <path d="m13.734-11.141c-0.4375-0.19531-0.87109-0.34375-1.2969-0.4375-0.41797-0.10156-0.83984-0.15625-1.2656-0.15625-1.2617 0-2.2305 0.40625-2.9062 1.2188-0.67969 0.80469-1.0156 1.9531-1.0156 3.4531v7.0625h-4.8906v-15.312h4.8906v2.5156c0.625-1 1.3438-1.7266 2.1562-2.1875 0.82031-0.46875 1.8008-0.70312 2.9375-0.70312 0.16406 0 0.34375 0.011719 0.53125 0.03125 0.19531 0.011719 0.47656 0.039062 0.84375 0.078125z"/>
        </symbol>
        <symbol id="a" overflow="visible">
        <path d="m17.641-7.7031v1.4062h-11.453c0.125 1.1484 0.53906 2.0078 1.25 2.5781 0.70703 0.57422 1.7031 0.85938 2.9844 0.85938 1.0312 0 2.082-0.14844 3.1562-0.45312 1.082-0.3125 2.1914-0.77344 3.3281-1.3906v3.7656c-1.1562 0.4375-2.3125 0.76562-3.4688 0.98438-1.1562 0.22656-2.3125 0.34375-3.4688 0.34375-2.7734 0-4.9297-0.70312-6.4688-2.1094-1.5312-1.4062-2.2969-3.3789-2.2969-5.9219 0-2.5 0.75391-4.4609 2.2656-5.8906 1.5078-1.4375 3.582-2.1562 6.2188-2.1562 2.4062 0 4.332 0.73047 5.7812 2.1875 1.4453 1.4492 2.1719 3.3828 2.1719 5.7969zm-5.0312-1.625c0-0.92578-0.27344-1.6719-0.8125-2.2344-0.54297-0.57031-1.25-0.85938-2.125-0.85938-0.94922 0-1.7188 0.26562-2.3125 0.79688s-0.96484 1.2969-1.1094 2.2969z"/>
        </symbol>
        <symbol id="l" overflow="visible">
        <path d="m9.2188-6.8906c-1.0234 0-1.793 0.17188-2.3125 0.51562-0.51172 0.34375-0.76562 0.85547-0.76562 1.5312 0 0.625 0.20703 1.1172 0.625 1.4688 0.41406 0.34375 0.98828 0.51562 1.7188 0.51562 0.92578 0 1.7031-0.32812 2.3281-0.98438 0.63281-0.66406 0.95312-1.4922 0.95312-2.4844v-0.5625zm7.4688-1.8438v8.7344h-4.9219v-2.2656c-0.65625 0.92969-1.3984 1.6055-2.2188 2.0312-0.82422 0.41406-1.8242 0.625-3 0.625-1.5859 0-2.8711-0.45703-3.8594-1.375-0.99219-0.92578-1.4844-2.1289-1.4844-3.6094 0-1.7891 0.61328-3.1016 1.8438-3.9375 1.2383-0.84375 3.1797-1.2656 5.8281-1.2656h2.8906v-0.39062c0-0.76953-0.30859-1.332-0.92188-1.6875-0.61719-0.36328-1.5703-0.54688-2.8594-0.54688-1.0547 0-2.0312 0.10547-2.9375 0.3125-0.89844 0.21094-1.7305 0.52344-2.5 0.9375v-3.7344c1.0391-0.25 2.0859-0.44141 3.1406-0.57812 1.0625-0.13281 2.125-0.20312 3.1875-0.20312 2.7578 0 4.75 0.54688 5.9688 1.6406 1.2266 1.0859 1.8438 2.8555 1.8438 5.3125z"/>
        </symbol>
        <symbol id="b" overflow="visible">
        <path d="m7.7031-19.656v4.3438h5.0469v3.5h-5.0469v6.5c0 0.71094 0.14062 1.1875 0.42188 1.4375s0.83594 0.375 1.6719 0.375h2.5156v3.5h-4.1875c-1.9375 0-3.3125-0.39844-4.125-1.2031-0.80469-0.8125-1.2031-2.1797-1.2031-4.1094v-6.5h-2.4219v-3.5h2.4219v-4.3438z"/>
        </symbol>
        <symbol id="k" overflow="visible">
        <path d="m12.766-13.078v-8.2031h4.9219v21.281h-4.9219v-2.2188c-0.66797 0.90625-1.4062 1.5703-2.2188 1.9844s-1.7578 0.625-2.8281 0.625c-1.8867 0-3.4336-0.75-4.6406-2.25-1.2109-1.5-1.8125-3.4258-1.8125-5.7812 0-2.3633 0.60156-4.2969 1.8125-5.7969 1.207-1.5 2.7539-2.25 4.6406-2.25 1.0625 0 2 0.21484 2.8125 0.64062 0.82031 0.42969 1.5664 1.0859 2.2344 1.9688zm-3.2188 9.9219c1.0391 0 1.8359-0.37891 2.3906-1.1406 0.55078-0.76953 0.82812-1.8828 0.82812-3.3438 0-1.457-0.27734-2.5664-0.82812-3.3281-0.55469-0.76953-1.3516-1.1562-2.3906-1.1562-1.043 0-1.8398 0.38672-2.3906 1.1562-0.55469 0.76172-0.82812 1.8711-0.82812 3.3281 0 1.4609 0.27344 2.5742 0.82812 3.3438 0.55078 0.76172 1.3477 1.1406 2.3906 1.1406z"/>
        </symbol>
        <symbol id="j" overflow="visible">
        <path d="m10.5-3.1562c1.0508 0 1.8516-0.37891 2.4062-1.1406 0.55078-0.76953 0.82812-1.8828 0.82812-3.3438 0-1.457-0.27734-2.5664-0.82812-3.3281-0.55469-0.76953-1.3555-1.1562-2.4062-1.1562-1.0547 0-1.8594 0.38672-2.4219 1.1562-0.55469 0.77344-0.82812 1.8828-0.82812 3.3281 0 1.4492 0.27344 2.5586 0.82812 3.3281 0.5625 0.77344 1.3672 1.1562 2.4219 1.1562zm-3.25-9.9219c0.67578-0.88281 1.4219-1.5391 2.2344-1.9688 0.82031-0.42578 1.7656-0.64062 2.8281-0.64062 1.8945 0 3.4453 0.75 4.6562 2.25 1.207 1.5 1.8125 3.4336 1.8125 5.7969 0 2.3555-0.60547 4.2812-1.8125 5.7812-1.2109 1.5-2.7617 2.25-4.6562 2.25-1.0625 0-2.0078-0.21094-2.8281-0.625-0.8125-0.42578-1.5586-1.0859-2.2344-1.9844v2.2188h-4.8906v-21.281h4.8906z"/>
        </symbol>
        <symbol id="i" overflow="visible">
        <path d="m0.34375-15.312h4.8906l4.125 10.391 3.5-10.391h4.8906l-6.4375 16.766c-0.64844 1.6953-1.4023 2.8828-2.2656 3.5625-0.86719 0.6875-2 1.0312-3.4062 1.0312h-2.8438v-3.2188h1.5312c0.83203 0 1.4375-0.13672 1.8125-0.40625 0.38281-0.26172 0.67969-0.73047 0.89062-1.4062l0.14062-0.42188z"/>
        </symbol>
        <symbol id="h" overflow="visible">
        <path d="m7.8281-16.438v12.453h1.8906c2.1562 0 3.8008-0.53125 4.9375-1.5938 1.1328-1.0625 1.7031-2.6133 1.7031-4.6562 0-2.0195-0.57031-3.5547-1.7031-4.6094-1.125-1.0625-2.7734-1.5938-4.9375-1.5938zm-5.25-3.9688h5.5469c3.0938 0 5.3984 0.21875 6.9219 0.65625 1.5195 0.4375 2.8203 1.1875 3.9062 2.25 0.95703 0.91797 1.6641 1.9805 2.125 3.1875 0.46875 1.1992 0.70312 2.5586 0.70312 4.0781 0 1.543-0.23438 2.918-0.70312 4.125-0.46094 1.2109-1.168 2.2773-2.125 3.2031-1.0938 1.0547-2.4062 1.8047-3.9375 2.25-1.5312 0.4375-3.8281 0.65625-6.8906 0.65625h-5.5469z"/>
        </symbol>
        <symbol id="c" overflow="visible">
        <path d="m9.6406-12.188c-1.0859 0-1.9141 0.39062-2.4844 1.1719-0.57422 0.78125-0.85938 1.9062-0.85938 3.375s0.28516 2.5938 0.85938 3.375c0.57031 0.77344 1.3984 1.1562 2.4844 1.1562 1.0625 0 1.875-0.38281 2.4375-1.1562 0.57031-0.78125 0.85938-1.9062 0.85938-3.375s-0.28906-2.5938-0.85938-3.375c-0.5625-0.78125-1.375-1.1719-2.4375-1.1719zm0-3.5c2.6328 0 4.6914 0.71484 6.1719 2.1406 1.4766 1.418 2.2188 3.3867 2.2188 5.9062 0 2.5117-0.74219 4.4805-2.2188 5.9062-1.4805 1.418-3.5391 2.125-6.1719 2.125-2.6484 0-4.7148-0.70703-6.2031-2.125-1.4922-1.4258-2.2344-3.3945-2.2344-5.9062 0-2.5195 0.74219-4.4883 2.2344-5.9062 1.4883-1.4258 3.5547-2.1406 6.2031-2.1406z"/>
        </symbol>
        <symbol id="g" overflow="visible">
        <path d="m16.547-12.766c0.61328-0.94531 1.3477-1.6719 2.2031-2.1719 0.85156-0.5 1.7891-0.75 2.8125-0.75 1.7578 0 3.0977 0.54688 4.0156 1.6406 0.92578 1.0859 1.3906 2.6562 1.3906 4.7188v9.3281h-4.9219v-7.9844-0.35938c0.007813-0.13281 0.015625-0.32031 0.015625-0.5625 0-1.082-0.16406-1.8633-0.48438-2.3438-0.3125-0.48828-0.82422-0.73438-1.5312-0.73438-0.92969 0-1.6484 0.38672-2.1562 1.1562-0.51172 0.76172-0.77344 1.8672-0.78125 3.3125v7.5156h-4.9219v-7.9844c0-1.6953-0.14844-2.7852-0.4375-3.2656-0.29297-0.48828-0.8125-0.73438-1.5625-0.73438-0.9375 0-1.6641 0.38672-2.1719 1.1562-0.51172 0.76172-0.76562 1.8594-0.76562 3.2969v7.5312h-4.9219v-15.312h4.9219v2.2344c0.60156-0.86328 1.2891-1.5156 2.0625-1.9531 0.78125-0.4375 1.6406-0.65625 2.5781-0.65625 1.0625 0 2 0.25781 2.8125 0.76562 0.8125 0.51172 1.4258 1.2305 1.8438 2.1562z"/>
        </symbol>
        <symbol id="f" overflow="visible">
        <path d="m2.3594-15.312h4.8906v15.312h-4.8906zm0-5.9688h4.8906v4h-4.8906z"/>
        </symbol>
        <symbol id="e" overflow="visible">
        <path d="m17.75-9.3281v9.3281h-4.9219v-7.1406c0-1.3203-0.03125-2.2344-0.09375-2.7344s-0.16797-0.86719-0.3125-1.1094c-0.1875-0.3125-0.44922-0.55469-0.78125-0.73438-0.32422-0.17578-0.69531-0.26562-1.1094-0.26562-1.0234 0-1.8242 0.39844-2.4062 1.1875-0.58594 0.78125-0.875 1.8711-0.875 3.2656v7.5312h-4.8906v-15.312h4.8906v2.2344c0.73828-0.88281 1.5195-1.5391 2.3438-1.9688 0.83203-0.42578 1.75-0.64062 2.75-0.64062 1.7695 0 3.1133 0.54688 4.0312 1.6406 0.91406 1.0859 1.375 2.6562 1.375 4.7188z"/>
        </symbol>
        <symbol id="u" overflow="visible">
        <path d="m2.3594-21.281h4.8906v11.594l5.625-5.625h5.6875l-7.4688 7.0312 8.0625 8.2812h-5.9375l-5.9688-6.3906v6.3906h-4.8906z"/>
        </symbol>
        <symbol id="t" overflow="visible">
        <path d="m2.5781-20.406h6.6875l4.6562 10.922 4.6719-10.922h6.6875v20.406h-4.9844v-14.938l-4.7031 11.016h-3.3281l-4.7031-11.016v14.938h-4.9844z"/>
        </symbol>
        <symbol id="s" overflow="visible">
        <path d="m12.422-21.281v3.2188h-2.7031c-0.6875 0-1.1719 0.125-1.4531 0.375-0.27344 0.25-0.40625 0.6875-0.40625 1.3125v1.0625h4.1875v3.5h-4.1875v11.812h-4.8906v-11.812h-2.4375v-3.5h2.4375v-1.0625c0-1.6641 0.46094-2.8984 1.3906-3.7031 0.92578-0.80078 2.3672-1.2031 4.3281-1.2031z"/>
        </symbol>
        <symbol id="r" overflow="visible">
        <path d="m17.75-9.3281v9.3281h-4.9219v-7.1094c0-1.3438-0.03125-2.2656-0.09375-2.7656s-0.16797-0.86719-0.3125-1.1094c-0.1875-0.3125-0.44922-0.55469-0.78125-0.73438-0.32422-0.17578-0.69531-0.26562-1.1094-0.26562-1.0234 0-1.8242 0.39844-2.4062 1.1875-0.58594 0.78125-0.875 1.8711-0.875 3.2656v7.5312h-4.8906v-21.281h4.8906v8.2031c0.73828-0.88281 1.5195-1.5391 2.3438-1.9688 0.83203-0.42578 1.75-0.64062 2.75-0.64062 1.7695 0 3.1133 0.54688 4.0312 1.6406 0.91406 1.0859 1.375 2.6562 1.375 4.7188z"/>
        </symbol>
        <symbol id="q" overflow="visible">
        <path d="m2.5781-20.406h5.875l7.4219 14v-14h4.9844v20.406h-5.875l-7.4219-14v14h-4.9844z"/>
        </symbol>
        <symbol id="p" overflow="visible">
        <path d="m2.1875-5.9688v-9.3438h4.9219v1.5312c0 0.83594-0.007813 1.875-0.015625 3.125-0.011719 1.25-0.015625 2.0859-0.015625 2.5 0 1.2422 0.03125 2.1328 0.09375 2.6719 0.070313 0.54297 0.17969 0.93359 0.32812 1.1719 0.20703 0.32422 0.47266 0.57422 0.79688 0.75 0.32031 0.16797 0.69141 0.25 1.1094 0.25 1.0195 0 1.8203-0.39062 2.4062-1.1719 0.58203-0.78125 0.875-1.8672 0.875-3.2656v-7.5625h4.8906v15.312h-4.8906v-2.2188c-0.74219 0.89844-1.5234 1.5586-2.3438 1.9844-0.82422 0.41406-1.7344 0.625-2.7344 0.625-1.7617 0-3.1055-0.53906-4.0312-1.625-0.92969-1.082-1.3906-2.6602-1.3906-4.7344z"/>
        </symbol>
        <symbol id="o" overflow="visible">
        <path d="m2.5781-20.406h8.7344c2.5938 0 4.582 0.57812 5.9688 1.7344 1.3945 1.1484 2.0938 2.7891 2.0938 4.9219 0 2.1367-0.69922 3.7812-2.0938 4.9375-1.3867 1.1562-3.375 1.7344-5.9688 1.7344h-3.4844v7.0781h-5.25zm5.25 3.8125v5.7031h2.9219c1.0195 0 1.8047-0.25 2.3594-0.75 0.5625-0.5 0.84375-1.2031 0.84375-2.1094 0-0.91406-0.28125-1.6172-0.84375-2.1094-0.55469-0.48828-1.3398-0.73438-2.3594-0.73438z"/>
        </symbol>
        <symbol id="n" overflow="visible">
        <path d="m2.3594-15.312h4.8906v15.031c0 2.0508-0.49609 3.6172-1.4844 4.7031-0.98047 1.082-2.4062 1.625-4.2812 1.625h-2.4219v-3.2188h0.85938c0.92578 0 1.5625-0.21094 1.9062-0.625 0.35156-0.41797 0.53125-1.2461 0.53125-2.4844zm0-5.9688h4.8906v4h-4.8906z"/>
        </symbol>
        <symbol id="m" overflow="visible">
        <path d="m14.719-14.828v3.9844c-0.65625-0.45703-1.3242-0.79688-2-1.0156-0.66797-0.21875-1.3594-0.32812-2.0781-0.32812-1.3672 0-2.4336 0.40234-3.2031 1.2031-0.76172 0.79297-1.1406 1.9062-1.1406 3.3438 0 1.4297 0.37891 2.543 1.1406 3.3438 0.76953 0.79297 1.8359 1.1875 3.2031 1.1875 0.75781 0 1.4844-0.10938 2.1719-0.32812 0.6875-0.22656 1.3203-0.56641 1.9062-1.0156v4c-0.76172 0.28125-1.5391 0.48828-2.3281 0.625-0.78125 0.14453-1.5742 0.21875-2.375 0.21875-2.7617 0-4.9219-0.70703-6.4844-2.125-1.5547-1.4141-2.3281-3.3828-2.3281-5.9062 0-2.5312 0.77344-4.5039 2.3281-5.9219 1.5625-1.4141 3.7227-2.125 6.4844-2.125 0.80078 0 1.5938 0.074219 2.375 0.21875 0.78125 0.13672 1.5547 0.35156 2.3281 0.64062z"/>
        </symbol>
      </defs>
      <g>
        <path d="m460.88 250.88v258.72h-339.92v-459.2h339.92v20.16h20.16v-30.238c0-2.8008-1.1211-5.0391-2.8008-7.2812-1.6797-1.6797-4.4805-2.8008-7.2812-2.8008h-360.08c-2.8008 0-5.5977 0.5625-7.2773 2.8008-2.2422 1.6797-2.8008 4.4805-2.8008 7.2812v479.92c0 2.8008 1.1211 5.0391 2.8008 7.2812 1.6797 1.6797 4.4805 2.8008 7.2812 2.8008h360.64c2.8008 0 5.0391-1.1211 7.2812-2.8008 1.6797-1.6797 2.8008-4.4805 2.8008-7.2812l-0.003907-269.36z"/>
        <path d="m500.08 87.922c-1.6797-1.6797-4.4805-2.8008-7.2812-2.8008s-5.0391 1.1211-7.2812 3.3594l-196.55 204.4c-3.9219 3.9219-3.9219 10.641 0.55859 14.559l43.121 41.441c1.6797 1.6797 4.4805 2.8008 7.2812 2.8008s5.0391-1.1211 7.2812-3.3594l196.56-204.96c3.9219-3.9219 3.9219-10.641-0.55859-14.559zm-161.28 239.12-28-27.438 182.56-190.4 28.559 27.441z"/>
        <path d="m596.4 74.48-43.121-41.441c-3.9219-3.9219-10.641-3.9219-14.559 0l-31.922 33.039c-3.9219 3.9219-3.9219 10.641 0 14.559l43.121 41.441c1.6797 1.6797 4.4805 2.8008 7.2812 2.8008s5.0391-1.1211 7.2812-3.3594l31.922-33.039c1.6797-1.6797 2.8008-4.4805 2.8008-7.2812-0.003906-2.2383-1.125-5.0391-2.8047-6.7188zm-39.199 25.758-28.559-27.438 17.359-18.48 28.559 27.441z"/>
        <path d="m237.44 417.2 63.84-22.961c1.6797-0.55859 2.8008-1.1211 3.9219-2.2383l20.16-21.281c1.6797-1.6797 2.8008-4.4805 2.8008-7.2812s-1.1211-5.0391-3.3594-7.2812l-43.121-41.441c-3.9219-3.9219-10.641-3.9219-14.559 0l-20.719 21.281c-1.1211 1.1211-1.6797 2.2383-2.2383 3.9219l-20.719 64.398c-1.1211 3.9219 0 7.8398 2.8008 10.641 3.3516 2.8047 7.2695 3.9219 11.191 2.2422zm25.758-68.32 11.762-12.32 28.559 27.441-11.762 11.762-42 15.121z"/>
        <path d="m169.68 89.602h256.48v20.16h-256.48z"/>
        <path d="m169.68 149.52h196.56v20.16h-196.56z"/>
        <path d="m169.68 210h136.64v20.16h-136.64z"/>
        <path d="m169.68 269.92h76.16v20.16h-76.16z"/>
        <path d="m169.68 329.84h31.359v20.16h-31.359z"/>
        <path d="m169.68 390.32h15.68v20.16h-15.68z"/>
      </g>
    </svg>
    """
  end

end
