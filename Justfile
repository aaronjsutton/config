set quiet := true
set no-exit-message := true

default: switch

nh    := require('nh')
nix   := require('nix')

machine := env('MACHINE_NAME')

[macos]
build:
  {{ nh }} darwin build .# -H {{ machine }}

[linux]
build:
  {{ nh }} os build .# -H {{ machine }}

[macos]
update:
  {{ nix }} flake update
  brew update
  brew upgrade
  brew upgrade --cask

[linux]
update:
  {{ nix }} flake update

[macos]
switch:
  {{ nh }} darwin switch .# -H {{ machine }}

[linux]
switch:
  {{ nh }} os switch .# -H {{ machine }}
