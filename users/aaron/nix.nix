{ pkgs-unstable, ... }:
{
  nix = {
    enable = true;

    settings = {
      download-buffer-size = 524288000 # 500 MiB
      ;
      warn-dirty = false;
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      trusted-users = [
        "root"
        "aaron"
        "@admin"
      ];
    };

    buildMachines = [ ];
    distributedBuilds = true;
    extraOptions = ''
      builders-use-substitutes = true
    '';
  };
}
