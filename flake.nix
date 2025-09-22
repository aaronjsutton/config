{
  description = "Aaron’s NixOS configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    systems.url = "github:nix-systems/default";

    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    wrapper-manager.url = "github:viperml/wrapper-manager";

    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nil.url = "github:oxalica/nil";
    jujutsu.url = "github:jj-vcs/jj";
    zig.url = "github:mitchellh/zig-overlay";
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      home-manager,
      wrapper-manager,
      darwin,
      ...
    }@inputs:
    let
      overlays = [
        inputs.jujutsu.overlays.default
        inputs.neovim-nightly-overlay.overlays.default
        inputs.nil.overlays.default
        inputs.zig.overlays.default
      ];

      mkSystem = import ./lib/mksystem.nix {
        inherit
          overlays
          nixpkgs
          inputs
          wrapper-manager
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

      nixosConfigurations.wsl = mkSystem "wsl" {
        system = "aarch64-linux";
        user = "aaron";
        wsl = true;
      };

      formatter = eachSystem (system: (import nixpkgs { inherit system; }).nixfmt-rfc-style);
    };

}
