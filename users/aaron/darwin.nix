{ pkgs, ... }:
{
  nixpkgs.overlays = import ../../lib/overlays.nix;

  homebrew = {
    enable = true;
    casks = [ "ghostty" ];
  };

  nix = {
    settings.trusted-users = [
      "root"
      "aaron"
      "@wheel"
    ];

    linux-builder.enable = true;

    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "hammond";
        protocol = "ssh-ng";
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
        systems = [ "x86_64-linux" ];
      }
    ];

    extraOptions = ''
      			builders-use-substitutes = true
      		'';
  };

  environment.pathsToLink = [ "/share/zsh" ];
  programs.zsh.enable = true;

  services.lorri.enable = true;

  networking.computerName = "Aaron’s MacBook Pro";
  networking.hostName = "lovelace";

  system.primaryUser = "aaron";

  users.users.aaron = {
    home = "/Users/aaron";
    shell = pkgs.zsh;
  };
}
