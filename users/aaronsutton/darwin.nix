{ inputs, pkgs, ...}: 

{ 
	homebrew = {
		enable = false;
	};

  users.users.aaronsutton = {
    home = "/Users/aaronsutton";
    shell = pkgs.zsh;
  };
}
