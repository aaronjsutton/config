NIXNAME ?= macbook-pro-m3

UNAME := $(shell uname)

switch:
ifeq ($(UNAME), Darwin)
	nix build --extra-experimental-features nix-command --extra-experimental-features flakes ".#darwinConfigurations.${NIXNAME}.system"
	./result/sw/bin/darwin-rebuild switch --flake "$$(pwd)#${NIXNAME}"
else
	sudo nixos-rebuild switch --flake ".#${NIXNAME}"
endif

check:
ifeq ($(UNAME), Darwin)
	nix build ".#darwinConfigurations.${NIXNAME}.system"
	./result/sw/bin/darwin-rebuild check --flake "$$(pwd)#${NIXNAME}"
else
	sudo nixos-rebuild check --flake ".#$(NIXNAME)"
endif

.PHONY: wsl
wsl:
	 nix build ".#nixosConfigurations.wsl.config.system.build.tarballBuilder"
