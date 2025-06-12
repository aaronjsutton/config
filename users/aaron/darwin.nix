{pkgs, ...}: {
  nixpkgs.overlays = import ../../lib/overlays.nix;

  homebrew = {
    enable = false;
  };

  environment.pathsToLink = ["/share/zsh"];
  programs.zsh.enable = true;

  networking.computerName = "Aaron’s MacBook Pro";
  networking.hostName = "lovelace";

	services.lorri.enable = true;
	
	# ^ ???
	system.primaryUser = "aaron";

  users.users.aaron = {
    home = "/Users/aaron";
    shell = pkgs.zsh;
  };
}
