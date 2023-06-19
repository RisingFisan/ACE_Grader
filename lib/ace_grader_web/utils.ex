defmodule AceGraderWeb.Utils do

  require AceGraderWeb.Gettext

  def get_keys(negative \\ false, func_name \\ nil) do
    get_translation = fn v -> Gettext.dgettext(AceGraderWeb.Gettext, "parameters", v) end
    program = Gettext.dgettext(AceGraderWeb.Gettext, "parameters", "Program")
    function = Gettext.dgettext(AceGraderWeb.Gettext, "parameters", "Function")
    uses = Gettext.dgettext(AceGraderWeb.Gettext, "parameters", "uses")
    doesn_t_use = Gettext.dgettext(AceGraderWeb.Gettext, "parameters", "doesn't use")
    is = Gettext.dgettext(AceGraderWeb.Gettext, "parameters", "is")
    isn_t = Gettext.dgettext(AceGraderWeb.Gettext, "parameters", "isn't")
    %{
      1 => "#{program} #{if negative, do: doesn_t_use, else: uses} #{get_translation.("recursion")}",
      2 => "#{program} #{if negative, do: doesn_t_use, else: uses} #{get_translation.("loops")}",
      3 => "#{program} #{if negative, do: doesn_t_use, else: uses} #{get_translation.("pointers")}",
      4 => "#{program} #{if negative, do: doesn_t_use, else: uses} #{get_translation.("dynamic memory")}",
      5 => "#{program} #{if negative, do: get_translation.("doesn't free"), else: get_translation.("frees")} #{get_translation.("allocated memory")}",
      10 => "#{function} #{if func_name != nil, do: "'" <> func_name <> "'", else: "X"} #{if negative, do: isn_t, else: is} #{get_translation.("used")}",
      11 => "#{function} #{if func_name != nil, do: "'" <> func_name <> "'", else: "X"} #{if negative, do: isn_t, else: is} #{Gettext.dpgettext(AceGraderWeb.Gettext, "parameters", "function", "recursive")}",
      12 => "#{function} #{if func_name != nil, do: "'" <> func_name <> "'", else: "X"} #{if negative, do: isn_t, else: is} #{Gettext.dpgettext(AceGraderWeb.Gettext, "parameters", "function", "iterative")}",
      13 => "#{function} #{if func_name != nil, do: "'" <> func_name <> "'", else: "X"} #{if negative, do: doesn_t_use, else: uses} #{get_translation.("pointers")}",
      14 => "#{function} #{if func_name != nil, do: "'" <> func_name <> "'", else: "X"} #{if negative, do: doesn_t_use, else: uses} #{get_translation.("dynamic memory")}",
      15 => "#{function} #{if func_name != nil, do: "'" <> func_name <> "'", else: "X"} #{if negative, do: get_translation.("doesn't free"), else: get_translation.("frees")} #{get_translation.("allocated memory")}"
    }
  end

end
