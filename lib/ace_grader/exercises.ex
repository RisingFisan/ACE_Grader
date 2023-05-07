defmodule AceGrader.Exercises do
  @moduledoc """
  The Exercises context.
  """

  import Ecto.Query, warn: false
  alias AceGrader.Repo

  alias AceGrader.Exercises.Exercise
  alias AceGrader.Exercises.Test
  alias AceGrader.Submissions.Submission

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
  def list_public_exercises do
    Repo.all(from(e in Exercise, where: e.public == true, order_by: [desc: e.inserted_at]))
  end

  # def list_exercises_by_user(user_id, only_public \\ true) do
  #   if only_public do
  #     Repo.all(from(e in Exercise, where: e.author_id == ^user_id and e.public == true, order_by: [desc: e.inserted_at]))
  #   else
  #     Repo.all(from(e in Exercise, where: e.author_id == ^user_id, order_by: [desc: e.inserted_at]))
  #   end
  # end

  def list_exercises_by_user(user_id, only_public \\ true) do
    Repo.all(from(e in Exercise, where: e.author_id == ^user_id and (e.public == true or ^only_public == false), order_by: [desc: e.inserted_at]))
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
  def get_exercise!(id, preloads \\ true, params \\ %{}) do
    Repo.get!(Exercise, id)
    |> Repo.preload([:user, tests: from(t in Test, order_by: [asc: t.position])])
    |> Repo.preload(if preloads, do: [submissions: from(get_submissions(params))], else: [])
  end

  defp get_submissions(params) do
    Submission
    |> join(:inner, [s], u in assoc(s, :user), as: :user)
    |> order_by(^sort_submissions_by(params["order_by"]))
    |> preload([s,u], [user: u])
  end

  defp sort_submissions_by("date_desc"), do: [desc: :inserted_at]
  defp sort_submissions_by("date_asc"), do: [asc: :inserted_at]
  defp sort_submissions_by("grade_desc"), do: [desc: :total_grade]
  defp sort_submissions_by("grade_asc"), do: [asc: :total_grade]
  defp sort_submissions_by("name_desc"), do: [desc: dynamic([user: u], u.username)]
  defp sort_submissions_by("name_asc"), do: [asc: dynamic([user: u], u.username)]
  defp sort_submissions_by(_), do: [desc: :inserted_at]

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
    |> Repo.preload([:tests, :submissions])
    |> Exercise.changeset(attrs)
  end

  def duplicate_exercise(%Exercise{} = exercise, user_id) do
    attrs = exercise
    |> Map.from_struct()
    |> Map.delete(:submissions)
    |> Map.update!(:tests, fn tests -> Enum.map(tests, & Map.from_struct(&1) |> Map.put(:temp_id, 0)) end)
    |> Map.put(:author_id, user_id)
    |> Map.update!(:title, fn title -> title <> " (copy)" end)

    %Exercise{}
    |> Exercise.changeset(attrs)
    |> Repo.insert()
  end
end
