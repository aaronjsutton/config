{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.shadowenv;
  exe = lib.getExe cfg.package;
in
{
  options.programs.shadowenv = {
    enable = lib.mkEnableOption "shadowenv";
    package = lib.mkPackageOption pkgs "shadowenv" { };
    enableZshIntegration = lib.hm.shell.mkZshIntegrationOption { inherit config; };
    enableNushellIntegration = lib.hm.shell.mkNushellIntegrationOption { inherit config; };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    programs.zsh.initContent = lib.mkIf cfg.enableZshIntegration ''
      eval "$(${exe} init zsh)"
    '';

    programs.nushell.extraConfig = lib.mkIf cfg.enableNushellIntegration (
      lib.mkAfter (builtins.replaceStrings [ "@shadowenv@" ] [ exe ] (builtins.readFile ./shadowenv.nu))
    );
  };
}
