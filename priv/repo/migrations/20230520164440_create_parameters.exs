defmodule AceGrader.Repo.Migrations.CreateParameters do
  use Ecto.Migration

  def change do
    create table(:parameters, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string
      add :grade, :integer
      add :visible, :boolean, default: false, null: false
      add :key, :integer
      add :value, :text
      add :description, :text
      add :position, :integer
      add :exercise_id, references(:exercises, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end
  end
end
