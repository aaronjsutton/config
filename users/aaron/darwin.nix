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
    "spotify"
    "steam"
    "zoom"
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

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = false;
    enableFastSyntaxHighlighting = true;
    enableFzfGit = false;
    enableFzfHistory = false;
    histSize = 9000;
    interactiveShellInit = builtins.readFile ./init.zsh;
    promptInit = builtins.readFile ./prompt.zsh;

    variables = {
      FZF_DEFAULT_OPTS="--height=10% --layout=reverse";
    };
  };
}
