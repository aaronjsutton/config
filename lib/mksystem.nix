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
  wsl ? false,
}:
let
  config = ../users/${user}/${if darwin then "darwin" else "nixos"}.nix;
  systemFunc = if darwin then inputs.darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  hm-modules = if darwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;
  pkgs-unstable = import nixpkgs-unstable { inherit system; };
in
systemFunc {
  modules = [
    {
      nixpkgs.hostPlatform.system = system;
      nixpkgs.overlays = overlays;
    }
    ../machines/${machine}.nix
    ../users/${user}/nix.nix
    config
    hm-modules.home-manager
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
