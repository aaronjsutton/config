{ config, lib, ... }:
{
  programs.nushell = {
    enable = true;
    settings = {
      show_banner = false;
      edit_mode = "vi";
    };
    # Shared aliases, minus `ls` so nushell keeps its structured builtin.
    shellAliases = lib.mkForce (builtins.removeAttrs config.home.shellAliases [ "ls" ]);
  };

  home.shell.enableNushellIntegration = true;
}
