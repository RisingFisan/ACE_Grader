defmodule AceGrader.Repo.Migrations.CreateTests do
  use Ecto.Migration

  def change do
    create table(:tests) do
      add :type, :string
      add :value, :text
      add :grade, :integer
      add :visible, :boolean, default: true, null: false

      timestamps()
    end
  end
end
