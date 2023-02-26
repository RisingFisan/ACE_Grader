defmodule AceGrader.Submissions.Submission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "submissions" do
    field :code, :string
    field :warnings, :string
    field :errors, :string
    field :success, :boolean, default: false
    field :executed, :boolean, default: false
    field :output, :string

    belongs_to :exercise, AceGrader.Exercises.Exercise

    timestamps()
  end

  @doc false
  def changeset(submission, attrs) do
    submission
    |> cast(attrs, [:code, :exercise_id, :warnings, :errors, :success, :executed, :output])
    |> validate_required([:code, :exercise_id])
  end
end
