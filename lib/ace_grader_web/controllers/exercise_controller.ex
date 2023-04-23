defmodule AceGraderWeb.ExerciseController do
  use AceGraderWeb, :controller

  alias AceGrader.Exercises
  alias AceGrader.Exercises.Exercise

  def index(conn, _params) do
    exercises =
      if !conn.assigns.current_user || conn.assigns.current_user.account_type == :student do
        Exercises.list_public_exercises()
      else
        Exercises.list_exercises()
      end
    render(conn, :index, exercises: exercises, page_title: "Exercises")
  end

  # def new(conn, _params) do
  #   changeset = Exercises.change_exercise(%Exercise{})
  #   render(conn, :form, changeset: changeset)
  # end

  # def create(conn, %{"exercise" => exercise_params}) do
  #   case Exercises.create_exercise(exercise_params) do
  #     {:ok, exercise} ->
  #       conn
  #       |> put_flash(:info, "Exercise created successfully.")
  #       |> redirect(to: ~p"/exercises/#{exercise}")

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       render(conn, :form, changeset: changeset)
  #   end
  # end

  def show(conn, %{"id" => id}) do
    exercise =
      if conn.assigns.current_user && conn.assigns.current_user.account_type == :student do
        Exercises.get_exercise!(id)
        |> Map.update!(:submissions, fn submissions ->
          Enum.filter(submissions, fn submission ->
            submission.author_id == conn.assigns.current_user.id
          end)
        end)
      else
        Exercises.get_exercise!(id, conn.assigns.current_user != nil)
      end
    is_owner = Exercise.is_owner?(exercise, conn.assigns.current_user)
    render(conn, :show, exercise: exercise, is_owner: is_owner)
  end

  def editor(conn, %{"id" => id}) do
    exercise = Exercises.get_exercise!(id)
    render(conn, :editor, exercise: exercise)
  end

  # def edit(conn, %{"id" => id}) do
  #   exercise = Exercises.get_exercise!(id)
  #   changeset = Exercises.change_exercise(exercise)
  #   render(conn, :form, exercise: exercise, changeset: changeset)
  # end

  # def update(conn, %{"id" => id, "exercise" => exercise_params}) do
  #   exercise = Exercises.get_exercise!(id)

  #   case Exercises.update_exercise(exercise, exercise_params) do
  #     {:ok, exercise} ->
  #       conn
  #       |> put_flash(:info, "Exercise updated successfully.")
  #       |> redirect(to: ~p"/exercises/#{exercise}")

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       render(conn, :form, exercise: exercise, changeset: changeset)
  #   end
  # end

  def delete(conn, %{"id" => id}) do
    exercise = Exercises.get_exercise!(id)
    if !Exercise.is_owner?(exercise, conn.assigns.current_user) do
      conn
      |> put_flash(:error, "You do not have permission to delete this exercise.")
      |> redirect(to: ~p"/exercises/#{exercise}")
    else
      {:ok, _exercise} = Exercises.delete_exercise(exercise)

      conn
      |> put_flash(:info, "Exercise deleted successfully.")
      |> redirect(to: ~p"/exercises")
    end
  end
end
