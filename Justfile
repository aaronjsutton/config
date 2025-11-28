set quiet

export HOSTNAME := "lovelace"

default: switch

build:
	nix build -v ".#darwinConfigurations.${HOSTNAME}.system"

[macos]
switch: build
	sudo ./result/sw/bin/darwin-rebuild switch --flake "$(pwd)#${HOSTNAME}"

[linux]
switch: build
    sudo nixos-rebuild switch --flake ".#${HOSTNAME}"

[macos]
check: build
    sudo ./result/sw/bin/darwin-rebuild check --flake "$(pwd)#${HOSTNAME}"

[linux]
check: build
    sudo nixos-rebuild check --flake ".#${HOSTNAME}"
