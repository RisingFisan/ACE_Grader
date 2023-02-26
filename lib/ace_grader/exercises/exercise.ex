defmodule AceGrader.Exercises.Exercise do
  use Ecto.Schema
  import Ecto.Changeset

  schema "exercises" do
    field :description, :string
    field :public, :boolean, default: true
    field :title, :string

    has_many :submissions, AceGrader.Submissions.Submission

    timestamps()
  end

  @doc false
  def changeset(exercise, attrs) do
    exercise
    |> cast(attrs, [:title, :description, :public])
    |> validate_required([:title, :description, :public])
  end
end
