{ pkgs-unstable, ... }:
{
  programs.btop = {
    enable = true;
    package = pkgs-unstable.btop;
    settings = {
      color_theme = "TTY";
      presets = "cpu:0:default,proc:0:default,net:0:default";
      theme_background = false;
      vim_keys = true;
    };
  };
}
