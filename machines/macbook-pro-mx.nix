{
  pkgs,
  ...
}:
{
  environment.shells = builtins.attrValues {
    inherit (pkgs)
      bashInteractive
      zsh
      ;
  };
  nixpkgs.config.allowUnfree = true;
  programs.zsh.enable = true;
  system.stateVersion = 6;
}
