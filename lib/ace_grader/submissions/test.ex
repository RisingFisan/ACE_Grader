defmodule AceGrader.Submissions.Test do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "submission_tests" do
    field :grade, :integer
    field :input, :string
    field :type, Ecto.Enum, values: [:exact, :regex, :items]
    field :expected_output, :string
    field :actual_output, :string
    field :visible, :boolean, default: false
    field :description, :string
    field :position, :integer
    # field :executed, :boolean, default: false
    # field :passed, :boolean, default: false
    field :status, Ecto.Enum, values: [:pending, :success, :failed, :timeout, :error], default: :pending

    belongs_to :submission, AceGrader.Submissions.Submission

    timestamps()
  end

  @doc false
  def changeset(test, attrs) do
    test
    |> cast(attrs, [:type, :input, :expected_output, :actual_output, :grade, :visible, :status, :description, :position])
    |> validate_required([:type, :expected_output, :grade, :visible])
    |> validate_inclusion(:grade, 0..100)
  end
end
