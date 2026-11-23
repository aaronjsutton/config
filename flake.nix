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
          coder-until = final.callPackage ./pkgs/coder-until {
            inherit (inputs.nixpkgs-unstable.legacyPackages.${final.stdenv.hostPlatform.system}) nushell;
          };
        })
      ];

      tests =
        system:
        import ./tests {
          pkgs = nixpkgs.legacyPackages.${system};
          pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
          inherit self inputs public;
        };

      work = [
        "strange-quark"
        "kaon"
      ];
      public = attrs: if inputs.private.stub or false then removeAttrs attrs work else attrs;

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
          modules = [ ./modules/homebrew/personal.nix ];
        };

        strange-quark = {
          machine = "macbook-pro-mx";
          system = "aarch64-darwin";
          user = "aaron";
          username = "aaronsutton";
          darwin = true;
          modules = [ ./modules/homebrew/work.nix ];
          homeModules = [
            ./modules/home-manager/coder
            inputs.private.homeManagerModules.default
          ];
        };
      };

      homeConfigurations = builtins.mapAttrs lib.mkHome {
        kaon = {
          system = "x86_64-linux";
          user = "coder";
          homeModules = [ inputs.private.homeManagerModules.default ];
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

      checks = {
        aarch64-darwin =
          public (builtins.mapAttrs (_: c: c.system) self.darwinConfigurations) // tests "aarch64-darwin";
        x86_64-linux =
          public {
            gluon = self.nixosConfigurations.gluon.config.system.build.toplevel;
            kaon = self.homeConfigurations.kaon.activationPackage;
          }
          // tests "x86_64-linux";
      };

      formatter = builtins.mapAttrs (_: pkgs: pkgs.nixfmt-tree) inputs.nixpkgs.legacyPackages;
    };
}
