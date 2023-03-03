defmodule AceGrader.Repo.Migrations.AddTestsExerciseId do
  use Ecto.Migration

  def change do
    alter table(:tests) do
      add :exercise_id, references(:exercises, on_delete: :delete_all)
    end
  end
end
