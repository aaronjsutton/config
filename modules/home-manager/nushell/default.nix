{ config, lib, ... }:
{
  programs.nushell = {
    enable = true;
    extraConfig = builtins.readFile ./prompt.nu + builtins.readFile ./coder.nu;
    settings = {
      show_banner = false;
      edit_mode = "vi";
      table.index_mode = "auto";
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
