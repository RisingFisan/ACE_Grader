defmodule AceGrader.Repo.Migrations.AddSubmissionOutput do
  use Ecto.Migration

  def change do
    alter table(:submissions) do
      add :warnings, :text
      add :errors, :text
      add :success, :boolean, default: false, null: false
      add :output, :text
    end
  end
end
