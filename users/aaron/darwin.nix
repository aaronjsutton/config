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

  # Legacy: Needed by `hombrew.enable`.
  # https://nix-darwin.github.io/nix-darwin/manual/#opt-system.primaryUser
  system.primaryUser = "aaron";
}
