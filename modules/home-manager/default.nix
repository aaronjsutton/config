{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./btop
    ./carapace
    ./claude
    ./delta
    ./eza
    ./fzf
    ./git
    ./jujutsu
    ./nh
    ./nushell
    ./nvim
    ./shadowenv
    ./zoxide
    ./zsh
  ];

  programs.home-manager.enable = true;
  programs.shadowenv.enable = true;

  home = {
    stateVersion = "25.05";
    packages = builtins.attrValues {
      inherit (pkgs.luaPackages)
        tree-sitter-cli
        ;
      inherit (pkgs)
        gh
        jq
        just
        nil
        ripgrep
        rsync
        tmux
        ;
    };

    sessionVariables = {
      EDITOR = "nvim";
    }
    // lib.optionalAttrs pkgs.stdenv.isDarwin {
      HOMEBREW_NO_AUTO_UPDATE = "1";
      HOMEBREW_NO_ENV_HINTS = "1";
    };
  };

  xdg.enable = true;
}
