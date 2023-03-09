defmodule AceGrader.Repo.Migrations.ChangeSubmissionTestsOnDelete do
  use Ecto.Migration

  def change do
    drop constraint(:submission_tests, "submission_tests_submission_id_fkey")

    alter table(:submission_tests) do
      modify :submission_id, references(:submissions, on_delete: :delete_all)
    end
  end
end
