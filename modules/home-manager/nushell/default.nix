{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.nushell = {
    enable = true;
    package = pkgs.nushell;
    extraConfig =
      lib.concatMapStrings builtins.readFile [
        ./theme.nu
        ./prompt.nu
        ./vz.nu
      ]
      + ''
        use ${./display.nu} *
      '';
    settings = {
      completions.algorithm = "fuzzy";
      show_banner = false;
      edit_mode = "vi";
      highlight_resolved_externals = true;
      table.index_mode = "auto";
      table.mode = "single";
    };
    shellAliases = lib.mkForce (
      builtins.removeAttrs config.home.shellAliases [
        "la"
        "ll"
        "ls"
        "lt"
      ]
      // {
        la = "ls -a";
        ll = "ls -l";
      }
    );
  };

  home.shell.enableNushellIntegration = true;
}
