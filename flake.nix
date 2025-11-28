{
  description = "Aaron’s NixOS configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";

    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
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

    jujutsu.url = "github:jj-vcs/jj";
    nil.url = "github:oxalica/nil";
    zig.url = "github:mitchellh/zig-overlay";
  };

  outputs =
    {
    darwin,
    home-manager,
    nixpkgs,
    self,
    systems,
    ...
    }@inputs:
    let
      overlays = [
        inputs.jujutsu.overlays.default
        inputs.neovim-nightly-overlay.overlays.default
        inputs.nil.overlays.default
        inputs.zig.overlays.default
        (final: prev: let
          system = prev.stdenv.hostPlatform.system;
          unstable = import inputs.nixpkgs-unstable {
            inherit system;
          };
        in {
          inherit (unstable) gh direnv;
        })
      ];

      mkSystem = import ./lib/mksystem.nix {
        inherit
          overlays
          nixpkgs
          inputs
          ;
      };

      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      darwinConfigurations.lovelace = mkSystem "macbook-pro-m3" {
        system = "aarch64-darwin";
        user = "aaron";
        darwin = true;
      };

      nixosConfigurations.hammond = mkSystem "dell-precision-3430" {
        system = "x86_64-linux";
        user = "aaron";
      };

      formatter = eachSystem (system: (import nixpkgs { inherit system; }).nixfmt-rfc-style);
    };
}
