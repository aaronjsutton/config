{
  pkgs,
  ...
}:
{
  system.stateVersion = 6;

  programs.zsh.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.shells = with pkgs; [ bashInteractive zsh ];
}
