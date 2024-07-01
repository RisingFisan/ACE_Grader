defmodule AceGraderWeb.Plugs.CheckAPIStatus do
  import Plug.Conn
  alias AceGrader.Grader.APIStatus

  def init(default), do: default

  def call(%Plug.Conn{} = conn, _default) do
    assign(conn, :api_status, APIStatus.get_status())
  end

end

defmodule AceGraderWeb.Plugs.Live.CheckAPIStatus do
  use Phoenix.LiveView
  alias AceGrader.Grader.APIStatus

  def on_mount(:default, _params, _session, socket) do
    {:cont, assign(socket, :api_status, APIStatus.get_status())}
  end

  def render(assigns) do
    ~H""
  end

end
