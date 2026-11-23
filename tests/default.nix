{
  pkgs,
  pkgs-unstable,
}:
let
  inherit (pkgs) lib;
  nushell = pkgs-unstable.callPackage ../pkgs/nushell { };
  nu = lib.getExe nushell;

  src = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.unions [
      (lib.fileset.fileFilter (f: lib.hasPrefix "test_" f.name) ./.)
      ../modules/home-manager/nushell/completion.nu
      ../modules/home-manager/nushell/display.nu
      ../modules/home-manager/coder/coder.nu
      ../modules/home-manager/shadowenv/shadowenv.nu
      ../pkgs/coder-until/coder-until.nu
    ];
  };
in
{
  nu = pkgs.runCommand "test-nu" { nativeBuildInputs = [ pkgs.shadowenv ]; } ''
    export HOME="$TMPDIR"
    cp -r ${src} src
    chmod -R u+w src
    cd src
    substituteInPlace modules/home-manager/coder/coder.nu \
      --replace-fail @completion@ "$PWD/modules/home-manager/nushell/completion.nu" \
      --replace-fail @display@ "$PWD/modules/home-manager/nushell/display.nu"
    substituteInPlace modules/home-manager/shadowenv/shadowenv.nu \
      --replace-fail @shadowenv@ ${lib.getExe pkgs.shadowenv}
    substituteInPlace pkgs/coder-until/coder-until.nu \
      --replace-fail @coder@ ^coder
    ${nu} --no-config-file -c '
      use ${nushell.src}/crates/nu-std/testing.nu
      testing run-tests --path tests
    '
    touch "$out"
  '';
}
