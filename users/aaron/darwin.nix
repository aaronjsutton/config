{ inputs, pkgs, ...}: 

{ 

	nixpkgs.overlays = import ../../lib/overlays.nix;

	homebrew = {
		enable = false;
	};

  users.users.aaron = {
    home = "/Users/aaron";
    shell = pkgs.zsh;
  };
}
