{
  lib,
  config,
  pkgs-unstable,
  username,
  ...
}:
let
  cfg = config.modules.nix;
in
{
  options.modules.nix = {
    enable = lib.mkEnableOption "System-wide Nix";
  };

  config = lib.mkIf cfg.enable {
    nix = {
      enable = true;
      package = pkgs-unstable.nixVersions.latest;

      settings = {
        download-buffer-size = 524288000; # 500 MiB
        warn-dirty = false;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        trusted-users = [
          "root"
          username
        ];
      };

      gc = {
        automatic = true;
        options = "--delete-older-than 30d";
      };
      optimise.automatic = true;
    };
  };
}
