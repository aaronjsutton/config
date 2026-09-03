#!/bin/bash
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --daemon

mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# nix run home-manager/release-26.05 -- switch --flake .#coder
# home-manager switch --flake .#codermkdir -p ~/.config/nix
