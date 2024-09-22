defmodule AceGrader.Submissions.Submission do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "submissions" do
    field :code, :string
    field :warnings, :string
    field :errors, :string
    field :status, Ecto.Enum, values: [:pending, :success, :error], default: :pending
    field :total_grade, :integer, default: 0

    has_many :tests, AceGrader.Submissions.Test
    has_many :parameters, AceGrader.Submissions.Parameter

    belongs_to :user, AceGrader.Accounts.User, foreign_key: :author_id
    belongs_to :exercise, AceGrader.Exercises.Exercise

    timestamps()
  end

  @doc false
  def changeset(submission, attrs) do
    submission
    |> cast(attrs, [:code, :exercise_id, :warnings, :errors, :status, :total_grade, :author_id])
    |> validate_required([:code, :exercise_id])
    |> cast_assoc(:tests)
    |> cast_assoc(:parameters)
  end

  def to_map(submission) do
    submission
    |> AceGrader.Repo.preload([:user, :tests, :parameters])
    |> Map.update!(:user, fn %{username: username, id: id} -> %{username: username, id: id}  end)
    |> Map.drop([:exercise, :__meta__, :author_id, :updated_at])
    |> Map.from_struct()
  end
end
