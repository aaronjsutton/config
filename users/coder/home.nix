{ ... }:
{
  imports = [ ../../modules/home-manager ];

  programs.nh.flake = "$HOME/.config/coderv2/dotfiles";
}
