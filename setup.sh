#!/bin/bash
set -euo pipefail

if ! command -v nix >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --daemon

  set +u
  for p in /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh \
           /nix/var/nix/profiles/default/etc/profile.d/nix.sh \
           "$HOME/.nix-profile/etc/profile.d/nix.sh"; do
    [[ -e "$p" ]] && . "$p" && break
  done
  set -u
fi

mkdir -p ~/.config/nix
grep -q '^experimental-features' ~/.config/nix/nix.conf 2>/dev/null \
  || echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

cd /home/coder/.config/coderv2/dotfiles
nix run home-manager/release-26.05 -- switch --flake .#coder
