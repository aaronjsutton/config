{ pkgs, ... }:
{
  users.users.aaron = {
    home = "/home/aaron";
    shell = pkgs.zsh;
    packages = [
      pkgs.ghostty
    ];
  };

  fonts.packages = [ ];

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

  secuirty.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
        if (action.id == "org.debian.pcsc-lite.access_card" &&
            subject.isInGroup("wheel")) {
            return polkit.Result.YES;
        }
    });
    polkit.addRule(function(action, subject) {
        if (action.id == "org.debian.pcsc-lite.access_pcsc" &&
            subject.isInGroup("wheel")) {
            return polkit.Result.YES;
        }
    });
  '';

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
}
