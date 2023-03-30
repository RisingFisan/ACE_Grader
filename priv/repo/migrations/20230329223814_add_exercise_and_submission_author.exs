defmodule AceGrader.Repo.Migrations.AddExerciseAndSubmissionAuthor do
  use Ecto.Migration

  def change do
    alter table(:exercises) do
      add :author_id, references(:users, on_delete: :delete_all, type: :binary_id)
    end

    alter table(:submissions) do
      add :author_id, references(:users, on_delete: :delete_all, type: :binary_id)
    end
  end
end
