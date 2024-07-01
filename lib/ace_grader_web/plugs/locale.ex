defmodule AceGraderWeb.Plugs.Locale do
  import Plug.Conn

  @locales ["en", "pt"]

  def init(default), do: default

  def get_session_locale(%Plug.Conn{assigns: %{current_user: %{locale: loc}}} = _conn, _default) when loc in @locales do
    loc
  end
  def get_session_locale(_conn, default), do: default


  def call(%Plug.Conn{params: %{"locale" => loc}} = conn, _default) when loc in @locales do
    Gettext.put_locale(AceGraderWeb.Gettext, loc)

    if conn.assigns.current_user do
      AceGrader.Accounts.update_user_info(conn.assigns.current_user, %{locale: loc})
    end

    conn
    |> put_session(:locale, loc)
    |> assign(:locale, loc)
  end
  def call(conn, default) do
    case get_session(conn, :locale) do
      nil ->
        loc = get_session_locale(conn, default)
        Gettext.put_locale(AceGraderWeb.Gettext, loc)

        put_session(conn, :locale, loc)
      loc ->
        Gettext.put_locale(AceGraderWeb.Gettext, loc)
        put_session(conn, :locale, loc)
    end
  end

end
