defmodule AceGrader.Exercises.Exercise do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "exercises" do
    field :description, :string
    field :public, :boolean, default: true
    field :title, :string

    field :total_grade, :integer, virtual: true

    has_many :submissions, AceGrader.Submissions.Submission
    has_many :tests, AceGrader.Exercises.Test

    timestamps()
  end

  @doc false
  def changeset(exercise, attrs) do
    tests = Map.get(attrs, "tests", %{}) |> dbg

    validate_grade = not Enum.any?(tests, fn {_key, test} -> test["grade"] == "" end)

    attrs = if validate_grade do
      sum = Enum.reduce(tests, 0, fn {_key, test}, acc -> acc + (if test["grade"] == "", do: 0, else: String.to_integer(test["grade"])) end)
      Map.put(attrs, "total_grade", sum)
    else
      attrs
    end

    exercise
    |> cast(attrs, [:title, :description, :public, :total_grade])
    |> validate_required([:title, :description, :public])
    |> cast_assoc(:tests)
    |> (& if validate_grade, do: validate_number(&1, :total_grade, equal_to: 100), else: &1).()
  end
end
