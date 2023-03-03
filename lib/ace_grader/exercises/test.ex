defmodule AceGrader.Exercises.Test do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tests" do
    field :grade, :integer
    field :type, Ecto.Enum, values: [:exact, :regex, :items]
    field :value, :string
    field :visible, :boolean, default: false

    field :temp_id, :string, virtual: true

    belongs_to :exercise, AceGrader.Exercises.Exercise

    timestamps()
  end

  @doc false
  def changeset(test, attrs) do
    test
    |> Map.put(:temp_id, (test.temp_id || attrs["temp_id"]))
    |> cast(attrs, [:type, :value, :grade, :visible])
    |> validate_required([:type, :value, :grade, :visible])
    |> validate_inclusion(:grade, 0..100)
  end
end
