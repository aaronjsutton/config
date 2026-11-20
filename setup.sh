#!/bin/bash
set -euo pipefail

# Load Nix's profile first: a non-login shell may not have Nix on PATH even
# when it is installed, and re-running the installer fails.
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

cd "$(dirname "$0")"
nix run --inputs-from . nixpkgs-unstable#nh -- home switch . -c coder
