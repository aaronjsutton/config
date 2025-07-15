{
  description = "NixOS systems and tools";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";

    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
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

  outputs = {
    self,
    nixpkgs,
    home-manager,
    darwin,
    ...
  } @ inputs: let
    overlays = [
				inputs.jujutsu.overlays.default
				inputs.neovim-nightly-overlay.overlays.default
				inputs.nil.overlays.default
				inputs.zig.overlays.default
    ];

    mkSystem = import ./lib/mksystem.nix {
      inherit overlays nixpkgs inputs;
    };
  in {
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
  };
}
