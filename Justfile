set quiet := true
set no-exit-message := true

default: switch

nh    := require('nh')
nix   := require('nix')

machine := env('MACHINE_NAME')

[macos]
build:
  {{ nh }} darwin build --no-nom .# -H {{ machine }}

[linux]
build:
  {{ nh }} os build --no-nom .# -H {{ machine }}

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
  {{ nh }} darwin switch --no-nom .# -H {{ machine }}

[linux]
switch:
  {{ nh }} os switch --no-nom .# -H {{ machine }}
