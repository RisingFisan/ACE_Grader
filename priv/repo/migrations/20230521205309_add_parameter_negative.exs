defmodule AceGrader.Repo.Migrations.AddParameterNegative do
  use Ecto.Migration

  def change do
    alter table(:parameters) do
      add :negative, :boolean, default: false, null: false
    end
  end
end
