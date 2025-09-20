{pkgs, /* wrapper-manager ,*/ ...}: 
# let
	#	wm-eval = wrapper-manager.lib {
	#    inherit pkgs;
	#		modules = [
	#			# import  modules here
	#		];
	#	};
# in
	{
	nixpkgs.overlays = import ../../lib/overlays.nix;

	homebrew = {
		enable = false;
	};

	nix = {
		settings.trusted-users = [ "root" "aaron" "@wheel" ];
		linux-builder.enable = true;
		distributedBuilds = true;
		buildMachines.hammond = {
			hostName = "hammond";	
			systems = [ "x86_64-linux" ];
		};
	};

  environment.pathsToLink = ["/share/zsh"];
  programs.zsh.enable = true;

	services.lorri.enable = true;

  networking.computerName = "Aaron’s MacBook Pro";
  networking.hostName = "lovelace";
	
	system.primaryUser = "aaron";

  users.users.aaron = {
    home = "/Users/aaron";
		# See: https://github.com/nix-darwin/nix-darwin/issues/779
		# shell = pkgs.nushell;
    shell = pkgs.zsh;
  };
}
