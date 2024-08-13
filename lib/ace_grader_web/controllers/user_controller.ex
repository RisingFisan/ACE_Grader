defmodule AceGraderWeb.UserController do
  use AceGraderWeb, :controller

  alias AceGrader.Accounts
  alias AceGrader.Exercises
  alias AceGrader.Submissions

  def show(conn, %{"username" => username}) do
    user = Accounts.get_user_by_username!(username)
    IO.inspect(user.email)
    assigns = %{
      user: user,
      page_title: "#{user.username}",
      exercises: (if user.account_type == :teacher, do: Exercises.list_exercises_by_user(user.id, conn.assigns.current_user == nil || user.id != conn.assigns.current_user.id), else: nil),
      submissions: (if user.account_type == :student && (conn.assigns.current_user.account_type != :student || conn.assigns.current_user.id == user.id), do: Submissions.list_submissions_by_user(user.id), else: nil)
    }
    render(conn, :show, assigns)
  end

end
