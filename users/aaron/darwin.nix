{ inputs, pkgs, ...}: 

{ 
	homebrew = {
		enable = false;
	};

  users.users.aaron = {
    home = "/Users/aaron";
    shell = pkgs.zsh;
  };
}
