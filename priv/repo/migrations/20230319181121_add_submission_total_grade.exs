defmodule AceGrader.Repo.Migrations.AddSubmissionTotalGrade do
  use Ecto.Migration

  def change do
    alter table(:submissions) do
      add :total_grade, :integer
    end
  end
end
