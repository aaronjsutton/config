{ pkgs, ... }: {
  nix.enable = true;
  nix.package = pkgs.nixVersions.latest;

  nix.settings = {
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


  # Configure the built-in Linux builder.
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
