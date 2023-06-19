defmodule AceGrader.Repo.Migrations.AddSubmissionStatus do
  use Ecto.Migration

  def change do
    alter table(:submissions) do
      add :status, :string, default: "pending"
      remove :success
    end
  end
end
