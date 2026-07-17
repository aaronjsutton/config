{
  nixpkgs,
  systems,
  overlays,
  inputs,
  ...
}:
let
  lib = nixpkgs.lib;

  config = {
    allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "codex"
      ];
  };
in
{
  mkSystem =
    machine:
    {
      system,
      user,
      darwin ? false,
    }:
    let
      mkSystem' = if darwin then inputs.nix-darwin.lib.darwinSystem else inputs.nixpkgs.lib.nixosSystem;
      pkgs-unstable = import inputs.nixpkgs-unstable { inherit config system; };

      machine-module = ../machines/${machine}.nix;
      os-module = ../users/${user}/${if darwin then "darwin" else "nixos"}.nix;
      nix-module = ../users/${user}/nix.nix;
      home-manager-module =
        if darwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;
    in
    mkSystem' {
      modules = [
        {
          _module.args = { inherit pkgs-unstable; };
          nixpkgs.hostPlatform.system = system;
          nixpkgs.overlays = overlays;
        }
        machine-module
        nix-module
        os-module
        home-manager-module.home-manager
        ../modules/zsh
        {
          home-manager.extraSpecialArgs = { inherit pkgs-unstable; };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${user} = ../users/${user}/home.nix;
        }
      ];
    };
}
