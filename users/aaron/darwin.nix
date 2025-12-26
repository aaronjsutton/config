{ pkgs, ... }:
{
  networking.computerName = "Aaron’s MacBook Pro";
  networking.hostName = "lovelace";

  users.users.aaron = {
    home = "/Users/aaron";
    shell = pkgs.zsh;
  };

  # Manage a few graphical apps via Homebrew. 
  # Graphical apps installed by Nix don't play nice with Spotlight, etc.
  homebrew.enable = true;
  homebrew.casks = [ 
    "slack" 
    "finch" 
    "ghostty" 
  ];
  
  # Legacy option needed by some parts of our configuration.
  # https://nix-darwin.github.io/nix-darwin/manual/#opt-system.primaryUser
  system.primaryUser = "aaron";
  
  # Experimental: Faster build times in direnv-enabled projects.
  services.lorri.enable = true;
  
  programs.direnv.enable = true;
  programs.direnv.settings = {
    global = {
      hide_env_diff = true;
      strict_env = true;
      warn_timeout = "1m0s";
    };
  };
}
