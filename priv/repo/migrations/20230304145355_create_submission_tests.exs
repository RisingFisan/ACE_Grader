defmodule AceGrader.Repo.Migrations.CreateSubmissionTests do
  use Ecto.Migration

  def change do
    create table(:submission_tests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string
      add :value, :text
      add :grade, :integer
      add :visible, :boolean, default: false, null: false
      add :submission_id, references(:submissions, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:submission_tests, [:submission_id])

    create index(:tests, [:exercise_id])
  end
end
