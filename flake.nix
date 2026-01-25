{
  description = "Aaron’s NixOS configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    systems.url = "github:nix-systems/default";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jujutsu = {
      url = "github:aaronjsutton/jj?ref=aaron/flake-warning";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    zig = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs =
    {
      darwin,
      home-manager,
      nixpkgs,
      nixpkgs-unstable,
      self,
      systems,
      ...
    }@inputs:
    let
      overlays = [
        inputs.neovim-nightly-overlay.overlays.default

        (import ./overlays { nixpkgs = nixpkgs-unstable; })
      ];

      mkSystem = import ./lib/mksystem.nix {
        inherit
          overlays
          nixpkgs
          nixpkgs-unstable
          inputs
          ;
      };

      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      darwinConfigurations.lovelace = mkSystem "macbook-pro-mx" {
        system = "aarch64-darwin";
        user = "aaron";
        darwin = true;
      };

      nixosConfigurations.hammond = mkSystem "dell-precision-3430" {
        system = "x86_64-linux";
        user = "aaron";
      };

      formatter = eachSystem (system: (import nixpkgs { inherit system; }).nixfmt-tree);
    };
}
