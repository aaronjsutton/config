{ pkgs-unstable, ... }:
{
  nix = {
    enable = true;

    settings = {
      download-buffer-size = 524288000 # 500 MiB
      ;
      warn-dirty = true;
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
}
