defmodule AceGraderWeb.ExerciseLive.Form do
  use AceGraderWeb, :live_view

  alias AceGrader.Exercises
  alias AceGrader.Exercises.Exercise

  def mount(_params = %{"id" => id}, _session, socket) do
    exercise = Exercises.get_exercise!(id) |> AceGrader.Repo.preload(:classes)
    if !Exercise.is_owner?(exercise, socket.assigns.current_user) do
      {:ok, socket |> put_flash(:error, "You must be this exercise's owner in order to perform this operation!") |> redirect(to: ~p"/exercises/#{id}")}
    else
      form = Exercises.change_exercise(exercise) |> to_form()
      {:ok, socket |> assign(
        form: form,
        exercise: exercise,
        valid_grades: true,
        page_title: "Edit Exercise",
        language: exercise.language,
        new_language: nil,
        classes: (if exercise.visibility == :class, do: AceGrader.Classes.list_classes(), else: nil),
        current_classes: exercise.classes) }
    end
  end

  def mount(_params, _session, socket) do
    exercise = %Exercise{}
    language = exercise.language
    form =
      Exercises.change_exercise(exercise, visibility: :public)
      |> Ecto.Changeset.put_assoc(:tests, [%Exercises.Test{temp_id: get_temp_id()}])
      |> Ecto.Changeset.put_change(:test_file, test_file(language))
      |> Ecto.Changeset.put_change(:template, template(language))
      |> to_form()
      # |> Ecto.Changeset.put_assoc(:parameters, [%Exercises.Parameter{temp_id: get_temp_id()}])
      # |> Ecto.Changeset.put_change(:test_file, """

      # """)
      # |> Ecto.Changeset.put_change(:template, )

    {:ok, socket |> assign(
      form: form,
      valid_grades: true,
      page_title: "New Exercise",
      language: language,
      new_language: nil,
      classes: nil,
      current_classes: [])
      # |> push_event("set_file_data", %{language: language, files: %{test_file: test_file(language), template: template(language)}})
    }
  end

  def test_file("c") do
    """
    #include <stdio.h>

    void hello_world();

    int main() {
        hello_world();

        return 0;
    }
    """
  end
  def test_file("haskell") do
    """
    main = do
      putStrLn $ hello_world
    """
  end

  def template("c") do
    """
    #include <stdio.h>

    void hello_world() {
        printf("Hello World!");
    }
    """
  end
  def template("haskell") do
    """
    hello_world = "Hello World!"
    """
  end

  def handle_event("validate", %{"exercise" => exercise_params} = _params, socket) do
    form =
      %Exercise{}
      |> Exercises.change_exercise(exercise_params)
      |> Map.put(:action, :validate)
      |> to_form()

    if {"visibility", "class"} in exercise_params do
      {:noreply, assign(socket, form: form, classes: AceGrader.Classes.list_classes())}
    else
      {:noreply, assign(socket, form: form)}
    end
  end

  def handle_event("change_language", %{"exercise" => %{"language" => new_language}} = _params, socket) do
      {:noreply, assign(socket, new_language: new_language)}
  end

  def handle_event("cancel_change_language", _params, socket) do
    {:noreply, socket |> push_event("undo_language_change", %{"language" => socket.assigns.language}) |> assign(new_language: nil)}
  end

  def handle_event("confirm_change_language", _params, socket) do
    new_language = socket.assigns.new_language
    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_change(:language, new_language)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset, language: new_language, new_language: nil)
    |> push_event("change_language", %{
      "language" => new_language,
      "template" => template(new_language),
      "test_file" => test_file(new_language)})}
  end

  def handle_event("save", %{"exercise" => exercise_params} = _params, socket) do
    exercise_params = exercise_params
      |> Map.put("author_id", socket.assigns.current_user.id)

    if socket.assigns[:exercise] do
      case Exercises.update_exercise(socket.assigns.exercise, exercise_params) do
        {:ok, exercise} ->
          {:noreply, socket
          |> put_flash(:info, "Exercise updated successfully.")
          |> push_navigate(to: ~p"/exercises/#{exercise}")}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, socket
          |> put_flash(:error, "Error updating exercise")
          |> assign(changeset: changeset)}
      end
    else
      case Exercises.create_exercise(exercise_params) |> dbg do
        {:ok, exercise} ->
          {:noreply, socket
          |> put_flash(:info, "Exercise created successfully.")
          |> push_navigate(to: ~p"/exercises/#{exercise}")}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, socket
          |> put_flash(:error, "Error creating exercise")
          |> assign(changeset: changeset)}
      end
    end
  end

  def handle_event("add-test", _params, socket) do
    existing_tests = Map.get(socket.assigns.changeset.changes, :tests, (if socket.assigns[:exercise], do: socket.assigns.exercise.tests, else: []))

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:tests,
        Enum.concat(existing_tests, [%Exercises.Test{temp_id: get_temp_id()}])
      )

    {:noreply,
     assign(socket,
       changeset: changeset
     )}
  end

  def handle_event("add-parameter", _params, socket) do
    existing_parameters = Map.get(socket.assigns.changeset.changes, :parameters, (if socket.assigns[:exercise], do: socket.assigns.exercise.parameters, else: []))

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:parameters,
        Enum.concat(existing_parameters, [%Exercises.Parameter{temp_id: get_temp_id()}])
      )

    {:noreply,
     assign(socket,
       changeset: changeset
     )}
  end

  def handle_event("change-slider", params = %{"_target" => [name]}, socket) do
    "manual_" <> xname = name
    value = Map.get(params, name)
    value = if value == "", do: "0", else: value
    case Integer.parse(value) do
      {n, ""} when n in 0..100 ->
        {:noreply, socket |> push_event("update-grade", %{"target_id" => xname, "target_grade" => n, "original_id" => name})}
      _ ->
        {:noreply, socket |> push_event("update-grade", %{"target_id" => name, "original_id" => xname})}
    end
  end

  defp get_temp_id, do: :crypto.strong_rand_bytes(5) |> Base.url_encode64

end
