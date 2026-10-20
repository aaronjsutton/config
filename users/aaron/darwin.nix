{ pkgs, username, ... }:
{
  users.users.${username}.shell = pkgs.zsh;

  security.pam.services.sudo_local.touchIdAuth = true;

  homebrew = {
    enable = true;
    user = username;
    enableZshIntegration = true;
    casks = [
      "ghostty"
      "openscad@snapshot"
    ];
  };
}
