{ nixpkgs, systems }:
{
  eachSystem =
    f:
    nixpkgs.lib.genAttrs (import systems) (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      f system pkgs
    );
}
