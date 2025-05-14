{ inputs, pkgs, ...}: 

{ 

	nixpkgs.overlays = import ../../lib/overlays.nix;

	homebrew = {
		enable = false;
	};

	programs.fish.enable = true;

	networking.computerName = "Aaron’s MacBook Pro";
	networking.hostName = "mac";

  users.users.aaron = {
    home = "/Users/aaron";
    shell = pkgs.fish;
  };
}
