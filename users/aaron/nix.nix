{ pkgs-unstable, ... }:
{
  nix.enable = true;
  nix.package = pkgs-unstable.nixVersions.latest;

  nix.settings = {
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

  nix.linux-builder = {
    enable = true;
    ephemeral = true;
    maxJobs = 4;
    config = {
      virtualisation = {
        darwin-builder = {
          diskSize = 40 * 1024;
          memorySize = 8 * 1024;
        };
        cores = 6;
      };
    };
  };

  nix.buildMachines = [ ];
  nix.distributedBuilds = true;

  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
}
