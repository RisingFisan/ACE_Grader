defmodule AceGrader.Repo.Migrations.AddTestInput do
  use Ecto.Migration

  def change do
    alter table(:tests) do
      add :input, :text
    end

    alter table(:submission_tests) do
      add :input, :text
    end
  end
end
