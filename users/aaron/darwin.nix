{pkgs, ...}: 
{
  nixpkgs.overlays = import ../../lib/overlays.nix;

  homebrew = {
    enable = false;
  };

	nix = {
		settings.trusted-users = [ "root" "aaron" "@wheel" ];
		linux-builder.enable = true;
	};

  environment.pathsToLink = ["/share/zsh"];
  programs.zsh.enable = true;

	services.lorri.enable = true;

  networking.computerName = "Aaron’s MacBook Pro";
  networking.hostName = "lovelace";
	
	system.primaryUser = "aaron";

  users.users.aaron = {
    home = "/Users/aaron";
    shell = pkgs.zsh;
  };
}
