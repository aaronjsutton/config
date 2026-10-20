{ config, lib, ... }:
let
  cfg = config.modules.zsh;
in
{
  options.modules.zsh = {
    enable = lib.mkEnableOption "System-wide ZSH";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.enable = true;
  };
}
