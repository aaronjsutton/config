{
  pkgs,
  pkgs-unstable,
}:
let
  inherit (pkgs) lib;
  nu = lib.getExe pkgs-unstable.nushell;

  src = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.unions [
      (lib.fileset.fileFilter (f: lib.hasPrefix "test_" f.name) ./.)
      ../modules/home-manager/shadowenv/shadowenv.nu
    ];
  };

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

  coderUntil = pkgs.writeText "coder-until.nu" (
    builtins.replaceStrings [ "def main [" "@coder@" ] [ "def coder-until [" "^coder" ] (
      builtins.readFile ../pkgs/coder-until/coder-until.nu
    )
  );
in
{
  nu = pkgs.runCommand "test-nu" { nativeBuildInputs = [ pkgs.shadowenv ]; } ''
    export HOME="$TMPDIR"
    cp -r ${src} src
    chmod -R u+w src
    cd src
    substituteInPlace modules/home-manager/shadowenv/shadowenv.nu \
      --replace-fail @shadowenv@ ${lib.getExe pkgs.shadowenv}
    ${nu} --no-config-file -c '
      use ${pkgs-unstable.nushell.src}/crates/nu-std/testing.nu
      testing run-tests --path tests
    '
    touch "$out"
  '';

  coder = nuTest "coder" {
    sources = [
      ./runner.nu
      ../modules/home-manager/nushell/completion.nu
      ../modules/home-manager/coder/coder.nu
      ./coder.nu
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
