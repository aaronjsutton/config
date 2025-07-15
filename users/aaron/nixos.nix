{pkgs, ...}: {
  environment.pathsToLink = ["/share/zsh"];

  environment.localBinInPath = true;

  programs.zsh.enable = true;

	services.lorri.enable = true;

  users.users.aaron = {
    isNormalUser = true;
    home = "/home/aaron";
    shell = pkgs.zsh;
		openssh.authorizedKeys.keys = [
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAxpIWQv9lBTM4jHlhbv1ufrBBPmmv4TzzPLPVKlQajO"
		];
  };
}
