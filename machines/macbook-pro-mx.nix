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
  system.stateVersion = 6;
}
