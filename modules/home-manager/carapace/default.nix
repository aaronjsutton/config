{ pkgs-unstable, ... }:
{
  programs.carapace = {
    enable = true;
    package = pkgs-unstable.carapace;
    enableZshIntegration = false;
  };
}
