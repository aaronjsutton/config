{ pkgs, ... }:
{
  networking.computerName = "Aaron’s MacBook Pro";
  networking.hostName = "lovelace";

  users.users.aaron = {
    home = "/Users/aaron";
    shell = pkgs.zsh;
  };

  homebrew.enable = true;
  homebrew.casks = [
    "blender"
    "finch"
    "ghostty"
    "loom"
    "slack"
    "steam"
  ];

  # Legacy: Needed by some parts of the configuration
  # https://nix-darwin.github.io/nix-darwin/manual/#opt-system.primaryUser
  system.primaryUser = "aaron";

  # Experimental: Faster build for direnv enabled projects
  services.lorri.enable = true;

  programs.direnv.enable = true;
  programs.direnv.settings = {
    global = {
      hide_env_diff = true;
      log_filter = "^$";
      log_format = "-";
      strict_env = true;
      warn_timeout = "300ms";
    };

    whitelist.prefix = [ "~/Code" ];
  };
}
