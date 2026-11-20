{ config, lib, ... }:
{
  programs.nushell = {
    enable = true;
    extraConfig = builtins.readFile ./prompt.nu + builtins.readFile ./coder.nu;
    settings = {
      show_banner = false;
      edit_mode = "vi";
    };
    # Shared aliases, minus `ls` so nushell keeps its structured builtin.
    shellAliases = lib.mkForce (builtins.removeAttrs config.home.shellAliases [ "ls" ]);
  };

  home.shell.enableNushellIntegration = true;
}
