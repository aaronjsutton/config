set quiet := true
set no-exit-message := true

nh  := require('nh')
nix := require('nix')

machine := env('MACHINE_NAME', `hostname -s`)
flavor  := if os() == "macos" { "darwin" } else if path_exists("/etc/NIXOS") == "true" { "os" } else { "home" }
target  := if flavor == "home" { "-c " + machine } else { "-H " + machine }

private  := `GIT_SSH_COMMAND='ssh -o BatchMode=yes' nix eval --impure -f stub/private/lock.nix private >/dev/null 2>&1 && echo true || echo false`
override := if private == "true" { "" } else { "--override-input private path:./stub/private" }

default: switch

build:
  {{ nh }} {{ flavor }} build .# {{ target }} -- {{ override }}

switch:
  {{ nh }} {{ flavor }} switch .# {{ target }} -- {{ override }}

[linux]
boot:
  {{ nh }} os boot .# -H {{ machine }} -- {{ override }}

update:
  {{ nix }} flake update {{ if private == "true" { "" } else { `nix eval --raw --impure -f stub/private/lock.nix public` } }}
  {{ if os() == "macos" { just_executable() + " brew" } else { "" } }}

[macos]
brew:
  brew update
  brew upgrade --greedy

check:
  {{ nix }} flake check {{ override }}

fmt:
  {{ nix }} fmt

clean:
  {{ nix }} store gc -v
  {{ nix }} store optimise -v
