defmodule AceGrader.Repo.Migrations.CreateSubmissions do
  use Ecto.Migration

  def change do
    create table(:submissions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :code, :text
      add :exercise_id, references(:exercises, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:submissions, [:exercise_id])
  end
end
