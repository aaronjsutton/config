{ pkgs, ... }:
{

  modules.zsh.enable = true;

  users.users = {
    aaron = {
      home = "/Users/aaron";
      shell = pkgs.zsh;
    };
  };

  networking = {
    computerName = "Aaron’s MacBook Pro";
    hostName = "lovelace";
  };

  homebrew = {
    enable = true;
    user = "aaron";
    enableZshIntegration = true;
    casks = [
      "ghostty"
      "google-chrome@canary"
      "loom"
      "slack"
      "spotify"
      "steam"
      "zoom"
    ];
  };
}
