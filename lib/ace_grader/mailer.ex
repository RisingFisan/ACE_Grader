defmodule AceGrader.Mailer do
  use Swoosh.Mailer, otp_app: :ace_grader

  def domain(), do: "sofiars.xyz" # replace with your own domain name
end
