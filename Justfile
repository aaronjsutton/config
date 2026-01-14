export MACHINE_NAME := "lovelace"

default: switch

[linux]
build:
	nix build ".#nixosConfigurations.${MACHINE_NAME}.system"

[macos]
build:
	nix build --show-trace --abort-on-warn ".#darwinConfigurations.${MACHINE_NAME}.system"

[linux]
switch: build
	sudo nixos-rebuild switch --flake ".#${MACHINE_NAME}"

[macos]
switch: build
	sudo ./result/sw/bin/darwin-rebuild switch --flake ".#${MACHINE_NAME}"
