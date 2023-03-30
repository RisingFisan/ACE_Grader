defmodule AceGrader.Repo.Migrations.AddUserInfo do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :username, :citext, null: false
      add :display_name, :string, null: false
      add :account_type, :string, null: false
    end

    create unique_index(:users, [:username])
  end
end
