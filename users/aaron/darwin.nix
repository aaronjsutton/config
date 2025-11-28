{ pkgs, ... }:
{
  homebrew = {
    enable = true;
    casks = [ 
      "slack" 
      "finch" 
      "ghostty" 
    ];
  };

  nix = {
    enable = true;

    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    settings.trusted-users = [
      "root"
      "aaron"
      "@admin"
    ];

    linux-builder = {
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

  system.primaryUser = "aaron";

  networking = {
    computerName = "Aaron’s MacBook Pro";
    hostName = "lovelace";
  };

  users.users.aaron = {
    home = "/Users/aaron";
    shell = pkgs.zsh;
  };
}
