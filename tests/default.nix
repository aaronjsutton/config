{
  pkgs,
  pkgs-unstable,
}:
let
  inherit (pkgs) lib;
  nu = lib.getExe pkgs-unstable.nushell;

  nuTest =
    name:
    {
      sources,
      path ? [ ],
    }:
    pkgs.runCommand "test-${name}" { nativeBuildInputs = path; } ''
      export HOME="$TMPDIR"
      ${nu} --no-config-file ${
        pkgs.writeText "${name}.nu" (lib.concatMapStrings (f: "source ${f}\n") sources)
      }
      touch "$out"
    '';

  shadowenvHook = pkgs.writeText "shadowenv.nu" (
    builtins.replaceStrings [ "@shadowenv@" ] [ (lib.getExe pkgs.shadowenv) ] (
      builtins.readFile ../modules/home-manager/shadowenv/shadowenv.nu
    )
  );

  coderUntil = pkgs.writeText "coder-until.nu" (
    builtins.replaceStrings [ "def main [" "@coder@" ] [ "def coder-until [" "^coder" ] (
      builtins.readFile ../pkgs/coder-until/coder-until.nu
    )
  );
in
{
  coder = nuTest "coder" {
    sources = [
      ./runner.nu
      ../modules/home-manager/nushell/completion.nu
      ../modules/home-manager/coder/coder.nu
      ./coder.nu
    ];
  };

  shadowenv = nuTest "shadowenv" {
    path = [ pkgs.shadowenv ];
    sources = [
      ./runner.nu
      shadowenvHook
      ./shadowenv.nu
    ];
  };

  coder-until = nuTest "coder-until" {
    sources = [
      ./runner.nu
      coderUntil
      ./coder-until.nu
    ];
  };
}
