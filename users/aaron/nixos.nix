{ pkgs, inputs, ... }:

{

	environment.pathsToLink = [ "/share/fish" ];

	# Add ~/.local/bin to PATH
	environment.localBinInPath = true;

	programs.fish.enable = true;

  users.users.aaron = {
    isNormalUser = true;
    home = "/home/aaron";
    shell = pkgs.fish;
  };
}
