{
  description = "NixOS systems and tools";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

		nixos-wsl.url = "github:nix-community/NixOS-WSL";
		nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

		home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

		neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

		jujutsu.url = "github:martinvonz/jj";
    zig.url = "github:mitchellh/zig-overlay";
  };

  outputs = { self, nixpkgs, home-manager, darwin, ... }@inputs: let
		overlays = [
			inputs.jujutsu.overlays.default
			inputs.zig.overlays.default
		];

		mkSystem = import ./lib/mksystem.nix {
			inherit overlays nixpkgs inputs;
		};
	in
		{

		darwinConfigurations.macbook-pro-m3 = mkSystem "macbook-pro-m3" {
      system = "aarch64-darwin";
      user   = "aaron";
      darwin = true;
    };

		nixosConfigurations.wsl = mkSystem "wsl" {
			system = "x86_64-linux";
			user = "aaron";
			wsl = true;
		};
	};
}
