defmodule AceGrader.Repo.Migrations.AddExerciseLanguage do
  use Ecto.Migration

  def change do
    alter table(:exercises) do
      add :language, :string, default: "c"
    end
  end
end
