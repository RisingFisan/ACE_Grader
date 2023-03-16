defmodule AceGrader.Repo.Migrations.CheckTestExecution do
  use Ecto.Migration

  def change do
    alter table(:submission_tests) do
      add :executed, :boolean, default: false, null: false
    end

    alter table(:submissions) do
      remove :executed
    end
  end
end
