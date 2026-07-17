{ ... }:

let
  theme = builtins.fetchTree {
    type = "github";
    owner = "zenbones-theme";
    repo = "zenbones.nvim";
    rev = "8304d8df9b823ff11e103afa62f38c39f534abe6";
  };
in
{
  xdg.configFile = {
    "ghostty" = {
      source = ./config;
      recursive = true;
    };
    "ghostty/themes/light" = {
      source = "${theme}/extras/ghostty/zenwritten_light";
    };
    "ghostty/themes/dark" = {
      source = "${theme}/extras/ghostty/zenwritten_dark";
    };
  };
}
