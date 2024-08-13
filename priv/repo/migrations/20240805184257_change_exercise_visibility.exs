defmodule AceGrader.Repo.Migrations.ChangeExerciseVisibility do
  use Ecto.Migration

  def change do

    create table(:exercises_classes, primary_key: false) do
      add :exercise_id, references(:exercises, on_delete: :delete_all, type: :binary_id)
      add :class_id, references(:classes, on_delete: :delete_all, type: :binary_id)
    end

    create index(:exercises_classes, [:class_id])

    # Add the new enum field
    alter table(:exercises) do
      add :visibility, :string
    end

    # Update existing records based on the boolean 'public' field
    execute("""
    UPDATE exercises
    SET visibility = CASE
      WHEN public = true THEN 'public'
      ELSE 'private'
    END
    ""","""
    UPDATE exercises
    SET public = CASE
      WHEN visibility = 'public' THEN true
      ELSE false
    END
    """)

    # Remove the old boolean 'public' field
    alter table(:exercises) do
      remove :public
    end
  end
end
