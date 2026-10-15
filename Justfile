set quiet := true
set no-exit-message := true

nh  := require('nh')
nix := require('nix')

machine := env('MACHINE_NAME', `hostname -s`)
flavor  := if os() == "macos" { "darwin" } else { "os" }

default: switch

build:
  {{ nh }} {{ flavor }} build --no-nom .# -H {{ machine }}

switch:
  {{ nh }} {{ flavor }} switch --no-nom .# -H {{ machine }}

update:
  {{ nix }} flake update
  {{ if os() == "macos" { just_executable() + " brew" } else { "" } }}

[macos]
brew:
  brew update
  brew upgrade --greedy

clean:
  {{ nix }} store gc -v
  {{ nix }} store optimise -v
