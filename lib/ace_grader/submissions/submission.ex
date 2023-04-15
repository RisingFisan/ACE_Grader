defmodule AceGrader.Submissions.Submission do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "submissions" do
    field :code, :string
    field :warnings, :string
    field :errors, :string
    field :success, :boolean, default: false
    field :total_grade, :integer

    has_many :tests, AceGrader.Submissions.Test

    belongs_to :user, AceGrader.Accounts.User, foreign_key: :author_id
    belongs_to :exercise, AceGrader.Exercises.Exercise

    timestamps()
  end

  @doc false
  def changeset(submission, attrs) do
    submission
    |> cast(attrs, [:code, :exercise_id, :warnings, :errors, :success, :total_grade, :author_id])
    |> validate_required([:code, :exercise_id])
    |> cast_assoc(:tests)
  end

  def pending_tests(submission) do
    length(Enum.filter(submission.tests, & &1.status == :pending)) > 0
  end
end
