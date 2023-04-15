defmodule AceGrader.Repo.Migrations.ChangeSubmissionTestStatus do
  use Ecto.Migration

  def change do
    alter table(:submission_tests) do
      add :status, :string, default: "pending"
      remove :executed
      remove :passed
    end
  end
end
