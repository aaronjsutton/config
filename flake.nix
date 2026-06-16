{
  description = "Aaron’s NixOS configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    systems.url = "github:nix-systems/default";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Bleeding Edge

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jujutsu = {
      url = "github:jj-vcs/jj";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.inputs.systems.follows = "systems";
    };
  };

  outputs =
    {
      nix-darwin,
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
        # inputs.jujutsu.overlays.default
      ];

      lib = import ./lib {
        inherit
          inputs
          overlays
          nixpkgs
          systems
          ;
      };

    in
    {
      darwinConfigurations.lovelace = lib.mkSystem "macbook-pro-mx" {
        system = "aarch64-darwin";
        user = "aaron";
        darwin = true;
      };

      nixosConfigurations.ritchie = lib.mkSystem "dell-precision-3430" {
        system = "x86_64-linux";
        user = "aaron";
      };

      devShells = lib.eachSystem (
        system: pkgs: {
          default = pkgs.mkShell {
            packages = builtins.attrValues {
              inherit (pkgs)
                nix-output-monitor
                ;
            };
          };
        }
      );

      formatter = lib.eachSystem (_: pkgs: pkgs.nixfmt-tree);
    };
}
