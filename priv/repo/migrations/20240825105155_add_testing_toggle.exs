defmodule AceGrader.Repo.Migrations.AddTestingToggle do
  use Ecto.Migration

  def change do
    alter table(:exercises) do
      add :testing_enabled, :boolean, default: false
    end
  end
end
