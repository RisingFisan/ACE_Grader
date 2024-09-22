defmodule AceGrader.Submissions.Parameter do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Jason.Encoder, only: [:submission_id, :description, :grade, :key, :negative, :status, :type, :value]}
  schema "submission_parameters" do
    field :description, :string
    field :grade, :integer
    field :key, :integer
    field :negative, :boolean, default: false
    field :position, :integer
    field :status, Ecto.Enum, values: [:pending, :success, :failed, :timeout, :error], default: :pending
    field :type, Ecto.Enum, values: [:optional, :graded, :mandatory]
    field :value, :string
    field :visible, :boolean, default: false
    field :submission_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(parameter, attrs) do
    parameter
    |> cast(attrs, [:type, :grade, :visible, :key, :value, :description, :position, :negative, :status])
    |> validate_required([:type, :visible, :key, :position, :negative])
    |> validate_grade()
    |> validate_value()
  end

  def validate_grade(changeset) do
    case get_change(changeset, :type) do
      :graded ->
        changeset
        |> validate_inclusion(:grade, 0..100)
      _ ->
        changeset
    end
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
end
