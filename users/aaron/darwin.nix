{ pkgs, ... }:
{

  modules = {
    nix.enable = true;
    zsh.enable = true;
  };

  users.users = {
    aaronsutton = {
      home = "/Users/aaronsutton";
      shell = pkgs.zsh;
    };
  };

  homebrew = {
    enable = true;
    user = "aaronsutton";
    enableZshIntegration = true;
    casks = [
      "ghostty"
      "macfuse"
    ];
  };
}
