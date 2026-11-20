set quiet := true
set no-exit-message := true

nh  := require('nh')
nix := require('nix')

machine := env('MACHINE_NAME', `hostname -s`)
flavor  := if os() == "macos" { "darwin" } else if path_exists("/etc/NIXOS") == "true" { "os" } else { "home" }
# nh os/darwin select by hostname; nh home picks `$USER@host` or `$USER` itself.
target  := if flavor == "home" { "" } else { "-H " + machine }

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
