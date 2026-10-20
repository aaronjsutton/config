{ pkgs, username, ... }:

{
  imports = [ ./hardware/dell-precision-3430.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
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
    AllowUsers = [ username ];
  };

  networking.firewall.enable = false;

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.all.forwarding" = 1;
    "net.ipv4.ip_no_pmtu_disc" = 1;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.all.send_redirects" = 0;
  };

  # Desktop
  programs.sway.enable = true;
  programs.waybar.enable = true;
  fonts.packages = [ pkgs.font-awesome ];

  users.users.${username}.packages = builtins.attrValues {
    inherit (pkgs)
      bambu-studio
      firefox
      ghostty
      openscad
      swaybg
      swayidle
      swaylock
      wl-clipboard
      ;
  };

  # YubiKey
  services = {
    udev.packages = [ pkgs.yubikey-personalization ];
    pcscd.enable = true;
  };

  system.stateVersion = "25.05";
}
