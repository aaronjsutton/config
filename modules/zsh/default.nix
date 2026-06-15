{ config, lib, ... }:
with lib;
let
  cfg = config.modules.zsh;
in
{
  options.modules.zsh = {
    enable = mkEnableOption "Aaron’s ZSH configuration";
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      enableFastSyntaxHighlighting = true;
      enableFzfHistory = false;
      histSize = 16384;
      interactiveShellInit = builtins.readFile ./interactive.zsh;
      promptInit = builtins.readFile ./prompt.zsh;
    };
  };
}
