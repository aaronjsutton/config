{
nixpkgs,
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
  home-manager =
    if darwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;
in
  systemFunc {
    modules = [
      { 
        nixpkgs = {
          hostPlatform.system = system;
          overlays = overlays; 
          config.allowUnfree = true;
        };
      }

      ../machines/${machine}.nix 
      ../users/${user}/nix.nix
      config 
      home-manager.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${user} = (import ../users/${user}/home.nix) {
          inputs = inputs;
        };
      }
      {
        config._module.args = {
          inherit machine;
          currentSystem = system;
          currentSystemUser = user;
          inputs = inputs;
        };
      }
    ];
  }
