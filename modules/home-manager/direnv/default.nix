{ ... }:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global = {
      hide_env_diff = true;
      log_filter = "^$";
      log_format = "-";
      strict_env = true;
      warn_timeout = "300ms";
    };
  };
}
