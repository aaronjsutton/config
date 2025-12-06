export NIX_NAME := "lovelace"

default: switch

build:
	nix build ".#darwinConfigurations.${NIX_NAME}.system"

[macos]
switch: build
	sudo ./result/sw/bin/darwin-rebuild switch --flake ".#${NIX_NAME}"

[linux]
switch: build
	sudo nixos-rebuild switch --flake ".#${NIX_NAME}"
