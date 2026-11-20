{ pkgs, pkgs-unstable }:
let
  inherit (pkgs) lib;
  nu = lib.getExe pkgs-unstable.nushell;

  nuTest =
    name: sources:
    pkgs.runCommand "test-${name}" { } ''
      export HOME="$TMPDIR"
      ${nu} --no-config-file ${
        pkgs.writeText "${name}.nu" (lib.concatMapStrings (f: "source ${f}\n") sources)
      }
      touch "$out"
    '';

  coderUntil = pkgs.writeText "coder-until.nu" (
    builtins.replaceStrings [ "def main [" "@coder@" ] [ "def coder-until [" "^coder" ] (
      builtins.readFile ../pkgs/coder-until/coder-until.nu
    )
  );
in
{
  coder = nuTest "coder" [
    ./runner.nu
    ../modules/home-manager/nushell/completion.nu
    ../modules/home-manager/coder/coder.nu
    ./coder.nu
  ];

  coder-until = nuTest "coder-until" [
    ./runner.nu
    coderUntil
    ./coder-until.nu
  ];
}
