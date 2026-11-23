#!/bin/bash
set -euo pipefail

load_nix() {
  set +u
  for p in /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh \
           /nix/var/nix/profiles/default/etc/profile.d/nix.sh \
           "$HOME/.nix-profile/etc/profile.d/nix.sh"; do
    [[ -e "$p" ]] && . "$p" && break
  done
  set -u
}

load_nix
if ! command -v nix >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --daemon
  load_nix
fi

mkdir -p ~/.config/nix
grep -q '^experimental-features' ~/.config/nix/nix.conf 2>/dev/null \
  || echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

mkdir -p -m 700 ~/.ssh
key='github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl'
grep -qxF "$key" ~/.ssh/known_hosts 2>/dev/null || echo "$key" >> ~/.ssh/known_hosts

cd "$(dirname "$0")"
nix run --inputs-from . nixpkgs-unstable#nh -- home switch . -c kaon
