defmodule AceGrader.Repo.Migrations.CreateClasses do
  use Ecto.Migration

  def change do
    create table(:classes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :creator_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:classes, [:creator_id], primary_key: false)

    create table(:classes_users, primary_key: false) do
      add :class_id, references(:classes, on_delete: :nothing, type: :binary_id)
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      # timestamps()
    end

    create index(:classes_users, [:class_id])
    create index(:classes_users, [:user_id])
  end
end
