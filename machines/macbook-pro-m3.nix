{
  pkgs,
  ...
}: {

	nix = {
		enable = true;
	  settings.experimental-features = [ "nix-command" "flakes" ];
	};

  programs.zsh.enable = true;

  environment.shells = with pkgs; [bashInteractive zsh fish];

  system.stateVersion = 6;
}
