defmodule AceGraderWeb.Plugs.Locale do
  import Plug.Conn

  @locales ["en", "pt"]

  def init(default), do: default

  def call(%Plug.Conn{params: %{"locale" => loc}} = conn, _default) when loc in @locales do
    Gettext.put_locale(AceGraderWeb.Gettext, loc)

    put_session(conn, :locale, loc)
    |> assign(:locale, loc)
  end

  def call(conn, default) do
    loc = get_session(conn, :locale) || default

    Gettext.put_locale(AceGraderWeb.Gettext, loc)

    assign(conn, :locale, loc)
  end
end
