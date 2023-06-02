defmodule AceGrader.Repo.Migrations.CreateSubmissionParameters do
  use Ecto.Migration

  def change do
    create table(:submission_parameters, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string
      add :grade, :integer
      add :visible, :boolean, default: false, null: false
      add :key, :integer
      add :value, :text
      add :description, :text
      add :position, :integer
      add :negative, :boolean, default: false, null: false
      add :status, :string
      add :submission_id, references(:submissions, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:submission_parameters, [:submission_id])
  end
end
