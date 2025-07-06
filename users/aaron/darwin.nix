{lib, pkgs, ...}: 

let
	darwin-builder = lib.nixosSystem {
		system = "aarch64-linux";
		modules = [
			"${pkgs}/nixos/modules/profiles/nix-builder-vm.nix"
			{
				virtualisation = {
					host.pkgs = pkgs;
					darwin-builder.workingDirectory = "/var/lib/darwin-builder";
					darwin-builder.hostPort = 22;
				};
			}
		];
	};
in
{
  nixpkgs.overlays = import ../../lib/overlays.nix;

  homebrew = {
    enable = false;
  };

	nix = {
		settings.trusted-users = [ "root" "aaron" "@wheel" ];
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

	launchd.daemons.darwin-builder = {
		command = "${darwin-builder.config.system.build.macos-builder-installer}/bin/create-builder";
		serviceConfig = {
			KeepAlive = true;
			RunAtLoad = true;
			StandardOutPath = "/var/log/darwin-builder.log";
			StandardErrorPath = "/var/log/darwin-builder.log";
		};
	};
}
