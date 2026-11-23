{ pkgs, ... }:
{
  home.packages = [
    pkgs.coder
    pkgs.coder-until
  ];

  programs.nushell.extraConfig = ''
    use ${
      pkgs.writeTextDir "coder.nu" (
        builtins.replaceStrings
          [ "@completion@" "@display@" ]
          [ "${../nushell/completion.nu}" "${../nushell/display.nu}" ]
          (builtins.readFile ./coder.nu)
      )
    }/coder.nu *
  '';

  programs.claude-code.skills.coder-stop-at = ./skill;
}
