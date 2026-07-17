{ config, lib, ... }:
with lib;
let
  cfg = config.modules.zsh;
in
{
  options.modules.zsh = {
    enable = mkEnableOption "System-wide ZSH";
  };

  config = mkIf cfg.enable {
    programs.zsh.enable = true;
  };
}
