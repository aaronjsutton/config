{ pkgs-unstable, ... }:
{
  programs.nh = {
    enable = true;
    package = pkgs-unstable.nh;
    flake = "$HOME/Code/config";
  };

  # Disable nix-output-monitor (nom) for nh build processes.
  home.sessionVariables.NH_NOM = "0";
}
