set quiet := true
set no-exit-message := true

default: switch

brew  := require('brew')
nh    := require('nh')
nix   := require('nix')

machine := env('MACHINE_NAME', 'lovelace')

[macos]
build:
  {{ nh }} darwin build

[macos]
update:
  {{ nix }} flake update
  {{ brew }} update
  {{ brew }} upgrade --cask

[macos]
switch:
  {{ nh }} darwin switch .# -H {{ machine }}
