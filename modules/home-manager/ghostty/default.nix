{ inputs, ... }:
{
  xdg.configFile = {
    "ghostty" = {
      source = ./config;
      recursive = true;
    };
    "ghostty/themes/light" = {
      source = "${inputs.zenbones}/extras/ghostty/zenwritten_light";
    };
    "ghostty/themes/dark" = {
      source = "${inputs.zenbones}/extras/ghostty/zenwritten_dark";
    };
  };
}
