{ config, lib, ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    enableCompletion = true;
    history.size = 16384;
    initContent = builtins.readFile ./init.zsh;
    syntaxHighlighting.enable = true;
  };

  home.shell.enableZshIntegration = true;

  home.shellAliases = {
    ag = "rg";
    j = "just";
    la = "eza --all";
    ll = "eza --long";
    ls = "eza";
    lt = "eza --tree";
    nq = "networkquality";
    ns = "networksetup";
    top = "btop";
    vi = "nvim";
    vim = "nvim";
  };
}
