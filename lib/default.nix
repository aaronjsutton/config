{
  nixpkgs,
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
        "terraform"
        "claude-code"
      ];
  };
in
{
  mkHome =
    {
      system,
      user,
      username ? user,
      homeDirectory ? "/home/${username}",
    }:
    let
      mkHome' = inputs.home-manager.lib.homeManagerConfiguration;
      pkgs-unstable = import inputs.nixpkgs-unstable { inherit config system; };
      pkgs = import nixpkgs {
        inherit config system overlays;
      };
    in
    mkHome' {
      inherit pkgs;
      extraSpecialArgs = { inherit pkgs-unstable; };
      modules = [
        ../users/${user}/home.nix
        {
          home = {
            inherit username homeDirectory;
          };
        }
      ];
    };

  mkSystem =
    machine:
    {
      system,
      user,
      username ? user,
      darwin ? false,
    }:
    let
      mkSystem' = if darwin then inputs.nix-darwin.lib.darwinSystem else inputs.nixpkgs.lib.nixosSystem;
      pkgs-unstable = import inputs.nixpkgs-unstable { inherit config system; };

      machine-module = ../machines/${machine}.nix;
      os-module = ../users/${user}/${if darwin then "darwin" else "nixos"}.nix;
      home-manager-module =
        if darwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;
    in
    mkSystem' {
      modules = [
        {
          _module.args = { inherit pkgs-unstable; };
          nixpkgs.hostPlatform.system = system;
          nixpkgs.overlays = overlays;
          nixpkgs.config = config;
        }
        machine-module
        os-module
        ../modules/nix
        ../modules/zsh
        home-manager-module.home-manager
        {
          home-manager = {
            extraSpecialArgs = { inherit pkgs-unstable; };
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${username} = ../users/${user}/home.nix;
          };
        }
      ];
    };
}
