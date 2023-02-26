defmodule AceGrader.Repo do
  use Ecto.Repo,
    otp_app: :ace_grader,
    adapter: Ecto.Adapters.Postgres
end
