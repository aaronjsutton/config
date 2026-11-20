{ pkgs, ... }:
{
  home.packages = [
    pkgs.coder
    pkgs.coder-until
  ];

  programs.nushell.extraConfig = builtins.readFile ./coder.nu;

  programs.claude-code.skills.coder-stop-at = ./skill;
}
