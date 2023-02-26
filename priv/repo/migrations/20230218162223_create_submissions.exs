defmodule AceGrader.Repo.Migrations.CreateSubmissions do
  use Ecto.Migration

  def change do
    create table(:submissions) do
      add :code, :text
      add :exercise_id, references(:exercises, on_delete: :delete_all)

      timestamps()
    end

    create index(:submissions, [:exercise_id])
  end
end
