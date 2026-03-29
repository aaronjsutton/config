{
  pkgs,
  ...
}:

{
  imports = [ ./hardware/dell-precision-3430.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = true;

  services.pcscd.enable = true;
  services.lorri.enable = true;

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

  programs.sway.enable = true;

  users.users.aaron = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    vim
    curl
  ];

  networking.interfaces.eno1.useDHCP = true;

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
