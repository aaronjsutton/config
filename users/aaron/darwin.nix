{ pkgs, pkgs-unstable, ... }:
{
  networking.computerName = "Aaron’s MacBook Pro";
  networking.hostName = "lovelace";

  system.defaults.loginwindow.GuestEnabled = false;

  modules.zsh.enable = true;

  users.users.aaron = {
    home = "/Users/aaron";
    shell = pkgs.zsh;
  };

  programs.direnv = {
    enable = true;
    package = pkgs-unstable.direnv;
    settings = {
      global = {
        hide_env_diff = true;
        log_filter = "^$";
        log_format = "-";
        strict_env = true;
        warn_timeout = "300ms";
      };

      whitelist.prefix = [ "~/Code" ];
    };
  };

  homebrew = {
    enable = true;
    casks = [
      "ghostty"
      "google-chrome@canary"
      "loom"
      "openscad"
      "slack"
      "spotify"
      "steam"
      "zoom"
    ];
  };

  # Legacy: Needed by `hombrew.enable` and `services.lorri.enable`
  # https://nix-darwin.github.io/nix-darwin/manual/#opt-system.primaryUser
  system.primaryUser = "aaron";

  # Experimental: Faster build for direnv enabled projects
  services.lorri.enable = true;

  # Experimental: Linux builder
  nix.linux-builder = {
    enable = true;
    ephemeral = true;
    maxJobs = 4;
    config = {
      virtualisation = {
        darwin-builder = {
          diskSize = 40 * 1024;
          memorySize = 8 * 1024;
        };
        cores = 6;
      };
    };
  };
}
