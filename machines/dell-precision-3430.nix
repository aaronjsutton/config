{
	pkgs,
	...
}: {

	imports = [
		./hardware/dell-precision-3430.nix
	];

	nix = {
		enable = true;
	  settings.experimental-features = [ "nix-command" "flakes" ];
	};

	boot.loader = {
    systemd-boot = {
      enable = true;
    };
    efi = {
      canTouchEfiVariables = false;
    };
    grub = {
      efiSupport = true;
      device = "nodev";
    };
  };

  boot.supportedFilesystems = ["ntfs"];

	networking = {
    hostName = "hammond";
    defaultGateway = "192.168.2.1";
		useDHCP = false;
    nameservers = [ "192.168.2.1" ];
    interfaces = {
      eno2.ipv4.addresses = [ {
        address = "192.168.2.2";
        prefixLength = 24;
      } ];
    };
  };

  programs.zsh.enable = true;

  environment.shells = with pkgs; [bashInteractive zsh];

  system.stateVersion = "25.05";
}
