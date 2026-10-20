{ pkgs, username, ... }:
{
  modules = {
    nix.enable = true;
    zsh.enable = true;
  };

  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

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
