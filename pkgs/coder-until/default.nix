{
  coder,
  lib,
  nushell,
  writeShellApplication,
  writers,
}:

let
  script = writers.writeNu "coder-until.nu" (
    builtins.replaceStrings [ "@coder@" ] [ "^${lib.getExe coder}" ] (builtins.readFile ./coder-until.nu)
  );
in
# nushell skips config.nu when running a script, so pass it explicitly to pick
# up the user's table style and theme. Fall back to no config if it's missing.
writeShellApplication {
  name = "coder-until";
  text = ''
    config="''${XDG_CONFIG_HOME:-$HOME/.config}/nushell/config.nu"
    if [ -f "$config" ]; then
      exec ${lib.getExe nushell} --config "$config" ${script} "$@"
    fi
    exec ${lib.getExe nushell} --no-config-file ${script} "$@"
  '';
}
