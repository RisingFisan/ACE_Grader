defmodule AceGraderWeb.RestoreLocale do
  use AceGraderWeb, :live_view

  def on_mount(:default, _params, %{"locale" => locale}, socket) do
    Gettext.put_locale(AceGraderWeb.Gettext, locale)
    {:cont, socket}
  end

  # catch-all case
  def on_mount(:default, _params, _session, socket), do: {:cont, socket}
end
