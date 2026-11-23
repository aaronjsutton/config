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
  system.tools.darwin-uninstaller.enable = false;
}
