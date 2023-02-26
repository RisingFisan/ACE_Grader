defmodule AceGraderWeb.ExerciseController do
  use AceGraderWeb, :controller

  alias AceGrader.Exercises
  alias AceGrader.Exercises.Exercise

  def index(conn, _params) do
    exercises = Exercises.list_exercises()
    render(conn, :index, exercises: exercises, page_title: "Exercises")
  end

  def new(conn, _params) do
    changeset = Exercises.change_exercise(%Exercise{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"exercise" => exercise_params}) do
    case Exercises.create_exercise(exercise_params) do
      {:ok, exercise} ->
        conn
        |> put_flash(:info, "Exercise created successfully.")
        |> redirect(to: ~p"/exercises/#{exercise}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    exercise = Exercises.get_exercise!(id)
    render(conn, :show, exercise: exercise)
  end

  def editor(conn, %{"id" => id}) do
    exercise = Exercises.get_exercise!(id)
    render(conn, :editor, exercise: exercise)
  end

  def edit(conn, %{"id" => id}) do
    exercise = Exercises.get_exercise!(id)
    changeset = Exercises.change_exercise(exercise)
    render(conn, :edit, exercise: exercise, changeset: changeset)
  end

  def update(conn, %{"id" => id, "exercise" => exercise_params}) do
    exercise = Exercises.get_exercise!(id)

    case Exercises.update_exercise(exercise, exercise_params) do
      {:ok, exercise} ->
        conn
        |> put_flash(:info, "Exercise updated successfully.")
        |> redirect(to: ~p"/exercises/#{exercise}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, exercise: exercise, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    exercise = Exercises.get_exercise!(id)
    {:ok, _exercise} = Exercises.delete_exercise(exercise)

    conn
    |> put_flash(:info, "Exercise deleted successfully.")
    |> redirect(to: ~p"/exercises")
  end
end
