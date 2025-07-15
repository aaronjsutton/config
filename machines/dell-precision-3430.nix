{
	pkgs,
	...
}: let
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAxpIWQv9lBTM4jHlhbv1ufrBBPmmv4TzzPLPVKlQajO aaronsutton@aarons-mbp.lan"
  ];
in{

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

  environment.systemPackages = with pkgs; [vim btop];

  networking = {
    hostName = "hammond";
		useDHCP = false;
    defaultGateway = "192.168.2.1";
    nameservers = [ "192.168.2.1" ];
    interfaces = {
      eno2.ipv4.addresses = [ {
        address = "192.168.2.2";
        prefixLength = 24;
      } ];
    };
  };

  time.timeZone = "America/New_York";

  users.users."aaron" = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = authorizedKeys;
  };

  users.groups.git = {};

  systemd.tmpfiles.rules = [
    "d /srv/git 0770 git git -"
  ];

  users.users."git" = {
    group = "git";
    isSystemUser = true;
    home = "/srv/git";
    shell = "${pkgs.git}/bin/git-shell";
    openssh.authorizedKeys.keys = authorizedKeys;
  };


  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.PubkeyAuthentication = true;
  };

  services.xserver = {
    autorun = false;
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
    displayManager.defaultSession = "xfce";
  };

  system.stateVersion = "23.05";
}
