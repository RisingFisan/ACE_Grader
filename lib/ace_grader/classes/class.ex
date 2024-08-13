defmodule AceGrader.Classes.Class do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "classes" do
    field :name, :string

    belongs_to :creator, AceGrader.Accounts.User, foreign_key: :creator_id

    many_to_many :members, AceGrader.Accounts.User, join_through: "classes_users"
    many_to_many :exercises, AceGrader.Exercises.Exercise, join_through: "exercises_classes"

    timestamps()
  end

  @doc false
  def changeset(class, attrs) do
    class
    |> cast(attrs, [:name, :creator_id])
    |> validate_required([:name, :creator_id])
  end
end
