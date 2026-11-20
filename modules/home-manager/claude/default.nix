{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  cfg = config.programs.claude-code;
  entries =
    dir: f:
    lib.optionalAttrs (builtins.pathExists dir) (
      lib.mapAttrs' (name: _: f name) (builtins.readDir dir)
    );
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
    agents = entries ./agents (
      name: lib.nameValuePair (lib.removeSuffix ".md" name) (./agents + "/${name}")
    );
    skills = entries ./skills (name: lib.nameValuePair name (./skills + "/${name}"));
  };

  # Pre-accept the folder trust dialog for ~/workspace. Trust lives in
  # ~/.claude.json, which is mutable state, so patch just that key in place.
  home.activation.claudeTrustWorkspace = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    f="$HOME/.claude.json"
    dir="$HOME/workspace"
    [ -s "$f" ] || echo '{}' > "$f"
    if [ "$(${lib.getExe pkgs.jq} --arg d "$dir" '.projects[$d].hasTrustDialogAccepted' "$f")" != "true" ]; then
      tmp="$(mktemp "$f.XXXXXX")"
      ${lib.getExe pkgs.jq} --arg d "$dir" '.projects[$d].hasTrustDialogAccepted = true' "$f" > "$tmp" && mv "$tmp" "$f"
    fi
  '';

  home.file = lib.mkIf (builtins.pathExists ./keybindings.json) {
    "${cfg.configDir}/keybindings.json".source = ./keybindings.json;
  };
}
