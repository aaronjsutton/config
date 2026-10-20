{
  description = "Aaron’s NixOS configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zenbones = {
      url = "github:zenbones-theme/zenbones.nvim";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      self,
      ...
    }@inputs:
    let
      overlays = [
        inputs.neovim-nightly-overlay.overlays.default
        (final: prev: {
          coder = final.callPackage ./pkgs/coder { };
        })
      ];

      lib = import ./lib {
        inherit
          inputs
          overlays
          nixpkgs
          ;
      };

    in
    {
      darwinConfigurations.lovelace = lib.mkSystem "macbook-pro-mx" {
        system = "aarch64-darwin";
        user = "aaron";
        darwin = true;
      };

      darwinConfigurations.strange-quark = lib.mkSystem "macbook-pro-mx" {
        system = "aarch64-darwin";
        user = "aaron";
        username = "aaronsutton";
        darwin = true;
      };

      nixosConfigurations.ritchie = lib.mkSystem "dell-precision-3430" {
        system = "x86_64-linux";
        user = "aaron";
      };

      homeConfigurations."coder" = lib.mkHome {
        system = "x86_64-linux";
        user = "coder";
      };

      checks = {
        aarch64-darwin = builtins.mapAttrs (_: c: c.system) self.darwinConfigurations;
        x86_64-linux = {
          ritchie = self.nixosConfigurations.ritchie.config.system.build.toplevel;
          coder = self.homeConfigurations.coder.activationPackage;
        };
      };

      formatter = builtins.mapAttrs (_: pkgs: pkgs.nixfmt-tree) inputs.nixpkgs.legacyPackages;
    };
}
