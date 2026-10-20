{ pkgs, username, ... }:
{
  modules = {
    nix.enable = true;
    zsh.enable = true;
  };

  fonts.packages = [ pkgs.font-awesome ];

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    packages = builtins.attrValues {
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
  };

  programs.sway.enable = true;
  programs.waybar.enable = true;

  services = {
    udev.packages = [ pkgs.yubikey-personalization ];
    pcscd.enable = true;
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.all.forwarding" = 1;
    "net.ipv4.ip_no_pmtu_disc" = 1;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.all.send_redirects" = 0;
  };
}
