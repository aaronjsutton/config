{
  config,
  lib,
  pkgs-unstable,
  ...
}:
let
  cfg = config.programs.claude-code;
  ifExists = path: default: if builtins.pathExists path then path else default;
in
{
  programs.claude-code = {
    enable = true;
    package = pkgs-unstable.claude-code;

    settings = {
      theme = "auto";
      awaySummaryEnabled = false;
      spinnerTipsEnabled = false;
      attribution = {
        commit = "";
        pr = "";
      };
    };

    context = ./CLAUDE.md;
    agentsDir = ifExists ./agents null;
    commandsDir = ifExists ./commands null;
    skills = ifExists ./skills { };
  };

  home.file = lib.mkIf (builtins.pathExists ./keybindings.json) {
    "${cfg.configDir}/keybindings.json".source = ./keybindings.json;
  };
}
