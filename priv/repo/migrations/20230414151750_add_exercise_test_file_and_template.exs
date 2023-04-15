defmodule AceGrader.Repo.Migrations.AddExerciseTestFileAndTemplate do
  use Ecto.Migration

  def change do
    alter table :exercises do
      add :test_file, :text
      add :template, :text
    end
  end
end
