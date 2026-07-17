{ config, ... }:
{
  programs.eza = {
    enable = true;
    git = true;
    extraOptions = [
      "--sort=ext"
    ];
  };

  xdg.configFile."eza" = {
    source = ./config;
    recursive = true;
  };

  home.sessionVariables = {
    EZA_CONFIG_DIR = "${config.xdg.configHome}/eza";
  };
}
