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

    private.url = "git+ssh://git@github.com/aaronjsutton/config-private";

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
          coder-until = final.callPackage ./pkgs/coder-until { };
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
      darwinConfigurations = builtins.mapAttrs lib.mkSystem {
        charm-quark = {
          machine = "macbook-pro-mx";
          system = "aarch64-darwin";
          user = "aaron";
          darwin = true;
          setHostName = true;
        };

        strange-quark = {
          machine = "macbook-pro-mx";
          system = "aarch64-darwin";
          user = "aaron";
          username = "aaronsutton";
          darwin = true;
          homeModules = [
            ./modules/home-manager/coder
            inputs.private.homeManagerModules.default
          ];
        };
      };

      nixosConfigurations = builtins.mapAttrs lib.mkSystem {
        gluon = {
          machine = "dell-precision-3430";
          system = "x86_64-linux";
          user = "aaron";
          setHostName = true;
        };
      };

      homeConfigurations = builtins.mapAttrs lib.mkHome {
        kaon = {
          system = "x86_64-linux";
          user = "coder";
          homeModules = [ inputs.private.homeManagerModules.default ];
        };
      };

      checks = {
        aarch64-darwin = builtins.mapAttrs (_: c: c.system) self.darwinConfigurations;
        x86_64-linux = {
          gluon = self.nixosConfigurations.gluon.config.system.build.toplevel;
          kaon = self.homeConfigurations.kaon.activationPackage;
        };
      };

      formatter = builtins.mapAttrs (_: pkgs: pkgs.nixfmt-tree) inputs.nixpkgs.legacyPackages;
    };
}
