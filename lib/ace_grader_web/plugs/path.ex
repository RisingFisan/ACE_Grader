defmodule AceGraderWeb.Plugs.SetCurrentPath do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    conn
    |> put_session(:current_path, conn.request_path)
    |> assign(:current_path, conn.request_path)
  end

end

defmodule AceGraderWeb.SetCurrentPath do
  def on_mount(:default, _params, _session, socket) do
    {:cont, Phoenix.LiveView.attach_hook(socket, :save_request_path, :handle_params, &save_request_path/3)}
  end

  defp save_request_path(_params, url, socket), do:
    {:cont, Phoenix.Component.assign(socket, :current_path, URI.parse(url).path)}
end
