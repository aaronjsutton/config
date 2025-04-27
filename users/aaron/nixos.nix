{ pkgs, inputs, ... }:

{
  users.users.aaron = {
    isNormalUser = true;
    home = "/home/aaron";
    shell = pkgs.zsh;
  };
}
