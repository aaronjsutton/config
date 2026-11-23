{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    enableCompletion = true;
    history.size = 16384;
    initContent = builtins.readFile ./init.zsh;
  };

  home.shell.enableZshIntegration = true;

  home.shellAliases = {
    ag = "rg";
    j = "just";
    la = "eza --all";
    ll = "eza --long";
    ls = "eza";
    lt = "eza --tree";
    top = "btop";
    vi = "nvim";
    vim = "nvim";
  }
  // lib.optionalAttrs pkgs.stdenv.isDarwin {
    nq = "networkquality";
    ns = "networksetup";
  };
}
