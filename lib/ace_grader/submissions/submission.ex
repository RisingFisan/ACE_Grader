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
    # field :status, Ecto.Enum, values: [:pending, :success, :error], default: :pending
    field :total_grade, :integer

    has_many :tests, AceGrader.Submissions.Test
    has_many :parameters, AceGrader.Submissions.Parameter

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
    |> cast_assoc(:parameters)
  end

  def pending_tests(submission) do
    length(Enum.filter(submission.tests, & &1.status in [:pending, :error])) > 0
    or
    length(Enum.filter(submission.parameters, & &1.status in [:pending, :error])) > 0
  end
end
