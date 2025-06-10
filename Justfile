set shell := ["bash", "-euxo", "pipefail", "-c"]

export NIXNAME := "miller"

default: switch

build:
	nix build \
		--extra-experimental-features nix-command \
		--extra-experimental-features flakes \
		".#darwinConfigurations.${NIXNAME}.system"

[macos]
switch: build
    sudo ./result/sw/bin/darwin-rebuild switch --flake "$(pwd)#${NIXNAME}"

[linux]
switch: build
    sudo nixos-rebuild switch --flake ".#${NIXNAME}"

[macos]
check: build
    sudo ./result/sw/bin/darwin-rebuild check --flake "$(pwd)#${NIXNAME}"

[linux]
check: build
    sudo nixos-rebuild check --flake ".#${NIXNAME}"
