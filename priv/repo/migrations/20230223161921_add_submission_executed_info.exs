defmodule AceGrader.Repo.Migrations.AddSubmissionExecutedInfo do
  use Ecto.Migration

  def change do
    alter table(:submissions) do
      add :executed, :boolean, default: false, null: false
    end
  end
end
