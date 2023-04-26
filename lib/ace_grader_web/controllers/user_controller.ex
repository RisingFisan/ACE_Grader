defmodule AceGraderWeb.UserController do
  use AceGraderWeb, :controller

  alias AceGrader.Accounts
  alias AceGrader.Exercises
  alias AceGrader.Submissions

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    assigns = %{
      user: user,
      page_title: "#{user.username}",
      exercises: (if user.account_type == :teacher, do: Exercises.list_exercises_by_user(user.id, user.id != conn.assigns.current_user.id), else: nil),
      submissions: (if user.account_type != :student || conn.assigns.current_user.id == user.id, do: Submissions.list_submissions_by_user(user.id), else: nil)
    }
    render(conn, :show, assigns)
  end

end
