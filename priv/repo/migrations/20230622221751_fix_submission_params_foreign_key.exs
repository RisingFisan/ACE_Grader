defmodule AceGrader.Repo.Migrations.FixSubmissionParamsForeignKey do
  use Ecto.Migration

  def change do
    drop constraint(:submission_parameters, "submission_parameters_submission_id_fkey")

    alter table(:submission_parameters) do
      modify :submission_id, references(:submissions, on_delete: :delete_all, type: :binary_id)
    end
  end
end
