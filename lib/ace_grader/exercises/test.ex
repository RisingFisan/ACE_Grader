defmodule AceGrader.Exercises.Test do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tests" do
    field :grade, :integer
    field :input, :string
    field :type, Ecto.Enum, values: [:exact, :regex, :items]
    field :expected_output, :string
    field :visible, :boolean, default: false

    field :actual_output, :string, virtual: true
    field :temp_id, :string, virtual: true

    belongs_to :exercise, AceGrader.Exercises.Exercise

    timestamps()
  end

  @doc false
  def changeset(test, attrs) do
    test
    |> Map.put(:temp_id, (test.temp_id || attrs["temp_id"]))
    |> cast(attrs, [:type, :input, :expected_output, :grade, :visible])
    |> validate_required([:type, :expected_output, :grade, :visible])
    |> validate_inclusion(:grade, 0..100)
  end
end
