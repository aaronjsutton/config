{ pkgs, ... }:

{

	environment.pathsToLink = [ "/share/zsh" ];

	environment.localBinInPath = true;

	programs.zsh.enable = true;

  users.users.aaron = {
    isNormalUser = true;
    home = "/home/aaron";
    shell = pkgs.zsh;
  };
}
