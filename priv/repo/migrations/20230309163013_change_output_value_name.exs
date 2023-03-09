defmodule AceGrader.Repo.Migrations.ChangeOutputValueName do
  use Ecto.Migration

  def change do
    rename table(:tests), :value, to: :expected_output
    rename table(:submission_tests), :value, to: :expected_output

    alter table(:submission_tests) do
      add :actual_output, :text
    end

    alter table(:submissions) do
      remove :output
    end
  end
end
