defmodule AceGrader.Exercises.Parameter do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "parameters" do
    field :description, :string
    field :grade, :integer
    field :key, :integer
    field :position, :integer
    field :type, Ecto.Enum, values: [:optional, :graded, :mandatory], default: :optional
    field :value, :string
    field :visible, :boolean, default: false
    field :negative, :boolean, default: false

    field :temp_id, :string, virtual: true
    field :delete, :boolean, virtual: true

    belongs_to :exercise, AceGrader.Exercises.Exercise

    timestamps()
  end

  @doc false
  def changeset(parameter, attrs) do
    parameter
    |> Map.put(:temp_id, (parameter.temp_id || attrs["temp_id"]))
    |> cast(attrs, [:type, :grade, :visible, :key, :value, :description, :position, :delete, :negative])
    |> validate_required([:type, :visible, :key, :negative])
    |> validate_grade()
    |> validate_value()
    |> maybe_mark_for_deletion()
  end

  # if key >= 10, validate required value, else ignore
  def validate_value(changeset) do
    case get_change(changeset, :key) do
      key when key != nil and key >= 10 ->
        changeset
        |> validate_required([:value])
      _ ->
        changeset
    end
  end

  def validate_grade(changeset) do
    case get_change(changeset, :type) do
      :graded ->
        changeset
        |> validate_required([:grade])
        |> validate_inclusion(:grade, 0..100)
      _ ->
        changeset
    end
  end

  defp maybe_mark_for_deletion(%{data: %{id: nil}} = changeset), do: changeset
  defp maybe_mark_for_deletion(changeset) do
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
