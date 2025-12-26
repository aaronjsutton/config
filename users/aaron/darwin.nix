{ pkgs, ... }:
{
  networking.computerName = "Aaron’s MacBook Pro";
  networking.hostName = "lovelace";

  users.users.aaron = {
    home = "/Users/aaron";
    shell = pkgs.zsh;
  };
  
  # Legacy option needed by some parts of our configuration.
  # https://nix-darwin.github.io/nix-darwin/manual/#opt-system.primaryUser
  system.primaryUser = "aaron";
  
  # Experimental: Use lorri for faster build times 
  # in direnv-enabled projects.
  services.lorri.enable = true;
  
  # Manage a few graphical apps via Homebrew. 
  # Graphical apps installed by Nix don't play nice with Spotlight, etc.
  homebrew.enable = true;
  homebrew.casks = [ 
    "slack" 
    "finch" 
    "ghostty" 
  ];
}
