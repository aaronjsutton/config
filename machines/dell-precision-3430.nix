{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./hardware/dell-precision-3430.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems = {
    "/".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
    "/nix".options = [
      "noatime"
      "compress=zstd"
    ];
  };

  networking.hostName = "ritchie";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.aaron = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [ ];
  };

  environment.systemPackages = with pkgs; [
    vim
    curl
  ];

  networking = {
    interfaces.eno1 = {
      ipv4.addresses = [
        {
          address = "192.168.2.3";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = {
      address = "192.168.2.1";
      interface = "eno1";
    };

  };

  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  services.openssh.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PermitRootLogin = "no";
    AllowUsers = [ "aaron" ];
  };

  networking.firewall.enable = false;

  system.stateVersion = "25.05";
}
