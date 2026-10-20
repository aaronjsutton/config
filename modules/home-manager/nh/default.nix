{ lib, pkgs-unstable, ... }:
{
  programs.nh = {
    enable = true;
    package = pkgs-unstable.nh;
    flake = lib.mkDefault "$HOME/@config";
  };
}
