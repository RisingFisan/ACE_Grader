defmodule AceGrader.Repo.Migrations.AddTestPosition do
  use Ecto.Migration

  def change do
    alter table(:tests) do
      add :position, :integer
    end

    alter table(:submission_tests) do
      add :position, :integer
    end
  end
end
