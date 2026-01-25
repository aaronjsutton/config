{ nixpkgs }:
final: prev:
let
  system = prev.stdenv.hostPlatform.system;
  pkgs = import nixpkgs {
    inherit system;
  };
in
{
  inherit (pkgs) jujutsu gh direnv nil;
}
