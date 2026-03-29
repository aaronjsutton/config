{ pkgs-unstable, ... }:
{
  nix.enable = true;
  nix.package = pkgs-unstable.nixVersions.latest;

  nix.settings = {
    download-buffer-size = 524288000 # 500 MiB
    ;
    warn-dirty = true;
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

  nix.buildMachines = [ ];
  nix.distributedBuilds = true;

  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
}
