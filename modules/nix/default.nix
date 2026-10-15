{
  lib,
  config,
  pkgs-unstable,
  ...
}:
with lib;
let
  cfg = config.modules.nix;
in
{
  options.modules.nix = {
    enable = mkEnableOption "System-wide Nix";
  };

  config = mkIf cfg.enable {
    nix = {
      enable = true;
      package = pkgs-unstable.nixVersions.latest;

      settings = {
        download-buffer-size = 524288000 # 500 MiB
        ;
        warn-dirty = false;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };

      buildMachines = [ ];
      distributedBuilds = true;
      extraOptions = ''
        builders-use-substitutes = true
      '';
    };
  };
}
