{ config, lib, ... }:
{
  programs.nushell = {
    enable = true;
    extraConfig = lib.concatMapStrings builtins.readFile [
      ./theme.nu
      ./prompt.nu
    ];
    settings = {
      show_banner = false;
      edit_mode = "vi";
      highlight_resolved_externals = true;
      table.index_mode = "auto";
      table.mode = "single";
    };
    # Shared aliases without eza; nushell's structured `ls` covers it.
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
