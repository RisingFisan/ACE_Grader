defmodule AceGrader.Submissions do
  @moduledoc """
  The Submissions context.
  """

  import Ecto.Query, warn: false
  alias Plug.Adapters.Test
  alias AceGrader.Repo

  alias AceGrader.Submissions.Submission
  alias AceGrader.Submissions.Test
  alias AceGrader.Submissions.Parameter

  @doc """
  Returns the list of submissions.

  ## Examples

      iex> list_submissions()
      [%Submission{}, ...]

  """
  def list_submissions do
    Repo.all(Submission)
  end

  def list_submissions_by_user(user_id) do
    Repo.all(from(s in Submission, where: s.author_id == ^user_id, order_by: [desc: s.inserted_at], preload: [:exercise]))
  end

  @doc """
  Gets a single submission.

  Raises `Ecto.NoResultsError` if the Submission does not exist.

  ## Examples

      iex> get_submission!(123)
      %Submission{}

      iex> get_submission!(456)
      ** (Ecto.NoResultsError)

  """
  def get_submission!(id) do
    Repo.get!(Submission, id)
    |> Repo.preload([:user, :exercise, tests: from(t in Test, order_by: [asc: t.position]), parameters: from(p in Parameter, order_by: [asc: p.position])])
  end

  @doc """
  Creates a submission.

  ## Examples

      iex> create_submission(%{field: value})
      {:ok, %Submission{}}

      iex> create_submission(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_submission(attrs \\ %{}) do
    %Submission{}
    |> Submission.changeset(attrs)
    |> Repo.insert()
  end

  def create_submission_from_changeset(changeset) do
    Repo.insert(changeset)
  end

  @doc """
  Updates a submission.

  ## Examples

      iex> update_submission(submission, %{field: new_value})
      {:ok, %Submission{}}

      iex> update_submission(submission, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_submission(%Submission{} = submission, attrs) do
    submission
    |> Submission.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a submission.

  ## Examples

      iex> delete_submission(submission)
      {:ok, %Submission{}}

      iex> delete_submission(submission)
      {:error, %Ecto.Changeset{}}

  """
  def delete_submission(%Submission{} = submission) do
    Repo.delete(submission)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking submission changes.

  ## Examples

      iex> change_submission(submission)
      %Ecto.Changeset{data: %Submission{}}

  """
  def change_submission(%Submission{} = submission, attrs \\ %{}) do
    submission
    |> Repo.preload([:tests, :parameters])
    |> Submission.changeset(attrs)
  end

  @doc """
  Gets a single submission test.

  Raises `Ecto.NoResultsError` if the Test does not exist.

  ## Examples

      iex> get_test!(123)
      %Test{}

      iex> get_test!(456)
      ** (Ecto.NoResultsError)

  """
  def get_test!(id) do
    Repo.get!(Test, id)
  end

  @doc """
  Updates a test.

  ## Examples

      iex> update_test(test, %{field: new_value})
      {:ok, %Test{}}

      iex> update_test(test, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_test(%Test{} = test, attrs) do
    test
    |> Test.changeset(attrs)
    |> Repo.update()
  end
end
