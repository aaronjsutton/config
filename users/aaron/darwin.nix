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

  homebrew = {
    enable = true;
    user = username;
    enableZshIntegration = true;
    casks = [
      "ghostty"
      "macfuse"
    ];
  };
}
