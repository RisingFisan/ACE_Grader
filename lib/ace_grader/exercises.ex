defmodule AceGrader.Exercises do
  @moduledoc """
  The Exercises context.
  """

  import Ecto.Query, warn: false
  alias AceGrader.Repo

  alias AceGrader.Exercises.Exercise
  alias AceGrader.Exercises.Test
  alias AceGrader.Exercises.Parameter

  @doc """
  Returns the list of exercises.

  ## Examples

      iex> list_exercises()
      [%Exercise{}, ...]

  """
  def list_exercises do
    Repo.all(from(e in Exercise, order_by: [desc: e.inserted_at]))
  end

  # define a function that lists every exercise, but in pages of 10
  # def list_exercises_page(page) do
  #   Repo.all(from(e in Exercise, order_by: e.inserted_at, limit: 10, offset: 10 * (page - 1)))
  # end

  @doc """
  Returns the list of public exercises.

  ## Examples

      iex> list_public_exercises()
      [%Exercise{}, ...]

  """
  def list_public_exercises(params \\ %{}) do
    languages_filter =
      if params[:languages] && params[:languages] != [] do
        dynamic([e], e.language in ^params[:languages])
      else
        true
      end

    if params[:user_id] do
      user = Repo.get(AceGrader.Accounts.User, params[:user_id]) |> Repo.preload(:classes)
      user_classes = user.classes |> Enum.map(& &1.id)
      Repo.all(from(
        e in Exercise,
        left_join: ec in AceGrader.Exercises.ExerciseClass, on: ec.exercise_id == e.id,
        where: e.visibility == :public or e.author_id == ^user.id or ec.class_id in ^user_classes,
        where: ^languages_filter,
        order_by: ^sort_exercises_by(params[:order_by])))
    else
      Repo.all(from(e in Exercise, where: e.visibility == :public, where: ^languages_filter, order_by: ^sort_exercises_by(params[:order_by])))
    end
  end

  defp sort_exercises_by("date_asc"), do: [asc: :inserted_at]
  defp sort_exercises_by("date_desc"), do: [desc: :inserted_at]
  defp sort_exercises_by("title_asc"), do: [asc: dynamic([e], fragment("lower(?)", e.title))]
  defp sort_exercises_by("title_desc"), do: [desc: dynamic([e], fragment("lower(?)", e.title))]
  defp sort_exercises_by(_), do: [desc: :inserted_at]

  # def list_exercises_by_user(user_id, only_public \\ true) do
  #   if only_public do
  #     Repo.all(from(e in Exercise, where: e.author_id == ^user_id and e.public == true, order_by: [desc: e.inserted_at]))
  #   else
  #     Repo.all(from(e in Exercise, where: e.author_id == ^user_id, order_by: [desc: e.inserted_at]))
  #   end
  # end

  def list_exercises_by_user(user_id, only_public \\ true, params \\ %{}) do
    languages_filter =
      if params[:languages] && params[:languages] != [] do
        dynamic([e], e.language in ^params[:languages])
      else
        true
      end
    Repo.all(from(
      e in Exercise,
      where: e.author_id == ^user_id and (e.visibility == :public or ^only_public == false),
      where: ^languages_filter,
      order_by: ^sort_exercises_by(params[:order_by]))
      )
  end

  def list_exercises_by_class(class_id, params \\ %{}) do
    languages_filter =
      if params[:languages] && params[:languages] != [] do
        dynamic([e], e.language in ^params[:languages])
      else
        true
      end
    Repo.all(
      from(e in Exercise,
        join: ec in AceGrader.Exercises.ExerciseClass, on: ec.exercise_id == e.id,
        join: c in AceGrader.Classes.Class, on: ec.class_id == c.id,
        where: c.id == ^class_id,
        where: ^languages_filter,
        order_by: ^sort_exercises_by(params[:order_by])
      )
    )
  end

  @doc """
  Gets a single exercise.

  Raises `Ecto.NoResultsError` if the Exercise does not exist.

  ## Examples

      iex> get_exercise!(123)
      %Exercise{}

      iex> get_exercise!(456)
      ** (Ecto.NoResultsError)

  """
  def get_exercise!(id) do
    Repo.get!(Exercise, id)
    |> Repo.preload([:user, tests: from(t in Test, order_by: [asc: t.position]), parameters: from(p in Parameter, order_by: [asc: p.position])])
  end

  @doc """
  Creates a exercise.

  ## Examples

      iex> create_exercise(%{field: value})
      {:ok, %Exercise{}}

      iex> create_exercise(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_exercise(attrs \\ %{}) do
    %Exercise{}
    |> Exercise.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a exercise.

  ## Examples

      iex> update_exercise(exercise, %{field: new_value})
      {:ok, %Exercise{}}

      iex> update_exercise(exercise, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_exercise(%Exercise{} = exercise, attrs) do
    exercise
    |> Exercise.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a exercise.

  ## Examples

      iex> delete_exercise(exercise)
      {:ok, %Exercise{}}

      iex> delete_exercise(exercise)
      {:error, %Ecto.Changeset{}}

  """
  def delete_exercise(%Exercise{} = exercise) do
    Repo.delete(exercise)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking exercise changes.

  ## Examples

      iex> change_exercise(exercise)
      %Ecto.Changeset{data: %Exercise{}}

  """
  def change_exercise(%Exercise{} = exercise, attrs \\ %{}) do
    exercise
    |> Repo.preload([:tests, :parameters, :submissions])
    |> Exercise.changeset(attrs)
  end

  def duplicate_exercise(%Exercise{} = exercise, user_id) do
    attrs = %{
      "title" => exercise.title <> " (copy)",
      "description" => exercise.description,
      "test_file" => exercise.test_file,
      "template" => exercise.template,
      "language" => exercise.language,
      "visibility" => "private",
      "tests" => Enum.map(exercise.tests, & Map.from_struct(&1) |> Map.drop(["id", "exercise_id"])),
      "parameters" => Enum.map(exercise.parameters, & Map.from_struct(&1) |> Map.drop(["id", "exercise_id"])),
      "author_id" => user_id,
      "testing_enabled" => exercise.testing_enabled
    }

    %Exercise{}
    |> Exercise.changeset_duplicate(attrs)
    |> Repo.insert()
  end
end
