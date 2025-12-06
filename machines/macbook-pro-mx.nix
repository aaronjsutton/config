{
  pkgs,
  ...
}:
{
  environment.shells = with pkgs; [ bashInteractive zsh ];
  nixpkgs.config.allowUnfree = true;
  programs.zsh.enable = true;
  system.stateVersion = 6;
}
