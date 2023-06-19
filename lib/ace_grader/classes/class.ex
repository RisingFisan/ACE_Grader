defmodule AceGrader.Classes.Class do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "classes" do
    field :name, :string

    belongs_to :user, AceGrader.Users.User, foreign_key: :creator_id

    many_to_many :users, AceGrader.Users.User, join_through: "classes_users"

    timestamps()
  end

  @doc false
  def changeset(class, attrs) do
    class
    |> cast(attrs, [:name, :creator_id])
    |> validate_required([:name, :creator_id])
    |> cast_assoc(:users)
  end
end
