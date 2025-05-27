set shell := ["bash", "-euxo", "pipefail", "-c"]

export NIXNAME := "macbook-pro-m3"

[macos]
switch:
    nix build \
      --extra-experimental-features nix-command \
      --extra-experimental-features flakes \
      ".#darwinConfigurations.${NIXNAME}.system"
    sudo ./result/sw/bin/darwin-rebuild switch --flake "$(pwd)#${NIXNAME}"

[linux]
switch:
    sudo nixos-rebuild switch --flake ".#${NIXNAME}"

[macos]
check:
    nix build ".#darwinConfigurations.${NIXNAME}.system"
    sudo ./result/sw/bin/darwin-rebuild check --flake "$(pwd)#${NIXNAME}"

[linux]
check:
    sudo nixos-rebuild check --flake ".#${NIXNAME}"

wsl:
		nix build ".#nixosConfigurations.wsl.config.system.build.tarballBuilder"
