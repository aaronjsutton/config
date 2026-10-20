{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
{
  imports = [
    ./btop
    ./delta
    ./direnv
    ./eza
    ./fzf
    ./git
    ./jujutsu
    ./nh
    ./nvim
    ./zoxide
    ./zsh
  ];

  programs.home-manager.enable = true;

  home = {
    stateVersion = "25.05";
    packages = builtins.attrValues {
      inherit (pkgs.luaPackages)
        tree-sitter-cli
        ;
      inherit (pkgs)
        awscli2
        gh
        jq
        just
        nil
        ripgrep
        rsync
        shadowenv
        tmux
        ;
      inherit (pkgs-unstable)
        claude-code
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
