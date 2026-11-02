{
  config,
  lib,
  pkgs-unstable,
  ...
}:
let
  cfg = config.programs.claude-code;
  # agents/, commands/, skills/ and keybindings.json are picked up once they exist here.
  ifExists = path: default: if builtins.pathExists path then path else default;
in
{
  programs.claude-code = {
    enable = true;
    package = pkgs-unstable.claude-code;

    # Non-empty so the module always manages settings.json (it skips writing it for { }).
    settings = {
      "$schema" = "https://json.schemastore.org/claude-code-settings.json";
    };

    context = ./CLAUDE.md;
    agentsDir = ifExists ./agents null;
    commandsDir = ifExists ./commands null;
    # Linked file by file, so org-synced skills in ~/.claude/skills are left alone.
    skills = ifExists ./skills { };
  };

  home.file = lib.mkIf (builtins.pathExists ./keybindings.json) {
    "${cfg.configDir}/keybindings.json".source = ./keybindings.json;
  };
}
