set quiet := true
set no-exit-message := true

nh  := require('nh')
nix := require('nix')

machine := env('MACHINE_NAME', `hostname -s`)
flavor  := if os() == "macos" { "darwin" } else if path_exists("/etc/NIXOS") == "true" { "os" } else { "home" }
target  := if flavor == "home" { "-c " + machine } else { "-H " + machine }

default: switch

build:
  {{ nh }} {{ flavor }} build .# {{ target }}

switch:
  {{ nh }} {{ flavor }} switch .# {{ target }}

[linux]
boot:
  {{ nh }} os boot .# -H {{ machine }}

update:
  {{ nix }} flake update
  {{ if os() == "macos" { just_executable() + " brew" } else { "" } }}

[macos]
brew:
  brew update
  brew upgrade --greedy

check:
  {{ nix }} flake check

fmt:
  {{ nix }} fmt

clean:
  {{ nix }} store gc -v
  {{ nix }} store optimise -v
