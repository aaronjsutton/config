set quiet

default: switch

machine := env('MACHINE_NAME', 'lovelace')

[linux]
build:
	nix build ".#nixosConfigurations.{{machine}}.system"

[macos]
build:
	nix build ".#darwinConfigurations.{{machine}}.system"

[macos]
update:
	brew update
	brew upgrade --cask

[linux]
switch: build
	sudo nixos-rebuild switch --flake ".#{{machine}}"

[macos]
switch: build
	sudo ./result/sw/bin/darwin-rebuild switch --flake ".#{{machine}}"

[unix]
gc: build
	sudo ./result/sw/bin/nix-collect-garbage -d

[macos]
list: build
	sudo ./result/sw/bin/darwin-rebuild --list-generations
