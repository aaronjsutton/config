{ pkgs, ... }:
{
  users.users.aaron = {
    home = "/home/aaron";
    shell = pkgs.zsh;
  };

  programs.direnv.enable = true;
  programs.direnv.package = pkgs.direnv;
  programs.direnv.settings = {
    global = {
      hide_env_diff = true;
      log_filter = "^$";
      log_format = "-";
      strict_env = true;
      warn_timeout = "300ms";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = false;
    syntaxHighlighting.enable = true;
    histSize = 9000;
    interactiveShellInit = builtins.readFile ./init.zsh;
    promptInit = builtins.readFile ./prompt.zsh;
  };
}
