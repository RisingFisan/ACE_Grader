defmodule AceGraderWeb.ExerciseLive.Form do
  use AceGraderWeb, :live_view

  alias AceGrader.Exercises
  alias AceGrader.Exercises.Exercise

  def mount(_params = %{"id" => id}, _session, socket) do
    exercise = Exercises.get_exercise!(id)
    changeset = Exercises.change_exercise(exercise)
    {:ok, socket |> assign(changeset: changeset, exercise: exercise, valid_grades: true)}
  end

  def mount(_params, _session, socket) do
    changeset = Exercises.change_exercise(%Exercise{})
      |> Ecto.Changeset.put_assoc(:tests, [%Exercises.Test{temp_id: get_temp_id()}])
    {:ok, socket |> assign(changeset: changeset, valid_grades: true)}
  end

  def handle_event("validate", %{"exercise" => exercise_params} = _params, socket) do
    tests = Map.get(exercise_params, "tests", %{})
    sum = Enum.reduce(tests, 0, fn {_key, test}, acc -> acc + (if test["grade"] == "", do: 0, else: String.to_integer(test["grade"])) end)

    valid_grades = sum == 100 or map_size(tests) == 0

    changeset =
      %Exercise{}
      |> Exercises.change_exercise(exercise_params |> Map.put("total_grade", sum))
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset, valid_grades: valid_grades)}
  end

  def handle_event("save", %{"exercise" => exercise_params} = _params, socket) do
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
    IO.inspect(socket.assigns)

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

  defp get_temp_id, do: :crypto.strong_rand_bytes(5) |> Base.url_encode64

end
