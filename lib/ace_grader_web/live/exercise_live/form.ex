defmodule AceGraderWeb.ExerciseLive.Form do
  use AceGraderWeb, :live_view

  alias AceGrader.Exercises
  alias AceGrader.Exercises.Exercise

  def mount(_params = %{"id" => id}, _session, socket) do
    exercise = Exercises.get_exercise!(id)
    if !Exercise.is_owner?(exercise, socket.assigns.current_user) do
      {:ok, socket |> put_flash(:error, "You must be this exercise's owner in order to perform this operation!") |> redirect(to: ~p"/exercises/#{id}")}
    else
      changeset = Exercises.change_exercise(exercise)
      {:ok, socket |> assign(changeset: changeset, exercise: exercise, valid_grades: true, page_title: "Edit Exercise", language: exercise.language)}
    end
  end

  def mount(_params, _session, socket) do
    changeset = Exercises.change_exercise(%Exercise{})
      |> Ecto.Changeset.put_assoc(:tests, [%Exercises.Test{temp_id: get_temp_id()}])
      # |> Ecto.Changeset.put_assoc(:parameters, [%Exercises.Parameter{temp_id: get_temp_id()}])
      # |> Ecto.Changeset.put_change(:test_file, """

      # """)
      # |> Ecto.Changeset.put_change(:template, )
    language = to_string(%Exercise{}.language)
    {:ok, socket |> assign(changeset: changeset, valid_grades: true, page_title: "New Exercise", language: language)
      |> push_event("set_file_data", %{language: language, files: %{test_file: test_file(language), template: template(language)}})}
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
    changeset =
      %Exercise{}
      |> Exercises.change_exercise(exercise_params)
      |> Map.put(:action, :validate)

    # if language changes
    if socket.assigns.language != exercise_params["language"] do
      {:noreply, assign(socket, changeset: changeset, language: exercise_params["language"])
        |> push_event("set_file_data", %{language: exercise_params["language"], files: %{test_file: test_file(exercise_params["language"]), template: template(exercise_params["language"])}})}
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("save", %{"exercise" => exercise_params} = _params, socket) do
    exercise_params = Map.put(exercise_params, "author_id", socket.assigns.current_user.id)
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

  def handle_event("remove-test", %{"remove" => remove_id}, socket) do
    tests =
      socket.assigns.changeset.changes.tests
      |> Enum.reject(fn %{data: test} ->
        test.temp_id == remove_id
      end)

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:tests, tests)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("remove-parameter", %{"remove" => remove_id}, socket) do
    parameters =
      socket.assigns.changeset.changes.parameters
      |> Enum.reject(fn %{data: parameter} ->
        parameter.temp_id == remove_id
      end)

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:parameters, parameters)

    {:noreply, assign(socket, changeset: changeset)}
  end

  defp get_temp_id, do: :crypto.strong_rand_bytes(5) |> Base.url_encode64

end
