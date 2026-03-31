{ pkgs, ... }:
{

  fonts.packages = builtins.attrValues {
    inherit (pkgs)
      font-awesome;
  };

  users.users.aaron = {
    home = "/home/aaron";
    shell = pkgs.zsh;
    packages = builtins.attrValues {
      inherit (pkgs)
        ghostty
        openscad
        bambu-studio
        wl-clipboard
        swaylock
        swayidle
        swaybg;
    };
  };

  services.lorri.enable = true;

  programs.waybar.enable = true;

  services = {
    udev.packages = [ pkgs.yubikey-personalization ];
    pcscd.enable = true;
  };

  programs.direnv.enable = true;
  programs.direnv.package = pkgs.direnv;
  programs.direnv.settings = {
    global = {
      hide_env_diff = true;
      log_filter = "^$";
      log_format = "-";
      strict_env = true;
      warn_timeout = "300ms";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = false;
    syntaxHighlighting.enable = true;
    histSize = 9000;
    interactiveShellInit = builtins.readFile ./init.zsh;
    promptInit = builtins.readFile ./prompt.zsh;
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

  services.strongswan = {
    enable = false;
    secrets = [ "/etc/ipsec.d/ipsec.secrets" ];

    setup = {
      charondebug = "ike 1, knl 1, cfg 0";
      uniqueids = "no";
    };

    connections = {
      internal = {
        auto = "add";
        compress = "no";
        type = "tunnel";
        keyexchange = "ikev2";
        fragmentation = "yes";
        forceencaps = "yes";
        dpdaction = "clear";
        dpddelay = "300s";
        send_cert = "always";
        rekey = "no";
        left = "%any";
        leftid = "192.168.2.3";
        leftcert = "server-cert.pem";
        leftsendcert = "always";
        leftsubnet = "0.0.0.0/0";
        right = "%any";
        rightid = "%any";
        rightauth = "eap-mschapv2";
        rightsourceip = "10.0.0.0/24";
        rightdns = "192.168.2.1";
        rightsendcert = "never";
        eap_identity="%identity";
        esp = "aes256-sha256-modp2048";
        ike = "aes256-sha256-modp2048-modpnone";
      };
    };
  };
}
