defmodule AceGrader.Repo.Migrations.AddTestDescription do
  use Ecto.Migration

  def change do
    alter table(:tests) do
      add :description, :text
    end

    alter table(:submission_tests) do
      add :description, :text
    end
  end
end
