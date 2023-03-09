defmodule AceGrader.Submissions.Submission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "submissions" do
    field :code, :string
    field :warnings, :string
    field :errors, :string
    field :success, :boolean, default: false
    field :executed, :boolean, default: false

    has_many :tests, AceGrader.Submissions.Test

    belongs_to :exercise, AceGrader.Exercises.Exercise

    timestamps()
  end

  @doc false
  def changeset(submission, attrs) do
    submission
    |> cast(attrs, [:code, :exercise_id, :warnings, :errors, :success, :executed])
    |> validate_required([:code, :exercise_id])
    |> cast_assoc(:tests)
  end
end
