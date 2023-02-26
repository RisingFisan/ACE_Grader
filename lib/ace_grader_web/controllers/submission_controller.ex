defmodule AceGraderWeb.SubmissionController do
  use AceGraderWeb, :controller

  alias AceGrader.Submissions
  alias AceGrader.Submissions.Submission
  alias AceGrader.Exercises

  # def index(conn, _params) do
  #   submissions = Submissions.list_submissions()
  #   render(conn, :index, submissions: submissions)
  # end

  # def new(conn, _params) do
  #   changeset = Submissions.change_submission(%Submission{})
  #   render(conn, :new, changeset: changeset)
  # end

  def create(conn, %{"submission" => submission_params, "exercise_id" => exercise_id}) do
    case Submissions.create_submission(submission_params) do
      {:ok, submission} ->
        conn
        |> put_flash(:info, "Submission created successfully.")
        |> redirect(to: ~p"/exercises/#{exercise_id}/submissions/#{submission}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id, "exercise_id" => exercise_id}) do
    exercise = Exercises.get_exercise!(exercise_id)
    submission = Submissions.get_submission!(id)
    render(conn, :show, submission: submission, exercise: exercise)
  end

  # def edit(conn, %{"id" => id}) do
  #   submission = Submissions.get_submission!(id)
  #   changeset = Submissions.change_submission(submission)
  #   render(conn, :edit, submission: submission, changeset: changeset)
  # end

  def update(conn, %{"id" => id, "exercise_id" => exercise_id, "submission" => submission_params}) do
    submission = Submissions.get_submission!(id)

    case Submissions.update_submission(submission, submission_params) do
      {:ok, submission} ->
        conn
        |> put_flash(:info, "Submission updated successfully.")
        |> redirect(to: ~p"/exercises/#{exercise_id}/submissions/#{submission}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, submission: submission, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id, "exercise_id" => exercise_id}) do
    submission = Submissions.get_submission!(id)
    {:ok, _submission} = Submissions.delete_submission(submission)

    conn
    |> put_flash(:info, "Submission deleted successfully.")
    |> redirect(to: ~p"/exercises/#{exercise_id}")
  end
end
