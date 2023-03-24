defmodule AceGrader.Repo.Migrations.AddSubmissionTestPassed do
  use Ecto.Migration

  def change do
    alter table(:submission_tests) do
      add :passed, :boolean, default: false, null: false
    end
  end
end
