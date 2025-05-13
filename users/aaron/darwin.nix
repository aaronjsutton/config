{ inputs, pkgs, ...}: 

{ 

	nixpkgs.overlays = import ../../lib/overlays.nix;

	homebrew = {
		enable = false;
	};

	programs.fish.enable = true;

  users.users.aaron = {
    home = "/Users/aaron";
    shell = pkgs.fish;
  };
}
