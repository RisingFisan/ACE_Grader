defmodule AceGrader.Repo.Migrations.CreateExercises do
  use Ecto.Migration

  def change do
    create table(:exercises) do
      add :title, :string
      add :description, :text
      add :public, :boolean, default: false, null: false

      timestamps()
    end
  end
end
