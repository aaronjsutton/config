{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  imports = [
    ../../modules/home-manager/btop
    ../../modules/home-manager/delta
    ../../modules/home-manager/eza
    ../../modules/home-manager/fzf
    ../../modules/home-manager/ghostty
    ../../modules/home-manager/git
    ../../modules/home-manager/jujutsu
    ../../modules/home-manager/nh
    ../../modules/home-manager/nvim
    ../../modules/home-manager/zoxide
    ../../modules/home-manager/zsh
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
