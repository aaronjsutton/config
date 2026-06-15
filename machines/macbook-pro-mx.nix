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
  system.stateVersion = 6;
}
