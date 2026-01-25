{
  nixpkgs,
  nixpkgs-unstable,
  overlays,
  inputs,
}:
machine:
{
  system,
  user,
  darwin ? false,
}:
let
  mkSystem' = if darwin then inputs.darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  pkgs-unstable = import nixpkgs-unstable { inherit system; };

  machine-module = ../machines/${machine}.nix;
  os-module = ../users/${user}/${if darwin then "darwin" else "nixos"}.nix;
  nix-module = ../users/${user}/nix.nix;
  home-manager-module =
    if darwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;
in
mkSystem' {
  modules = [
    {
      _module.args = { inherit pkgs-unstable; };
      nixpkgs.hostPlatform.system = system;
      nixpkgs.overlays = overlays;
    }
    machine-module
    nix-module
    os-module
    home-manager-module.home-manager
    {
      home-manager.extraSpecialArgs = { inherit pkgs-unstable; };
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = (import ../users/${user}/home.nix) {
        inputs = inputs;
      };
    }
  ];
}
