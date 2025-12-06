{
  nixpkgs,
  overlays,
  inputs,
}:
name:
{
  system,
  user,
  darwin ? false,
  wsl ? false,
}:
let

  isWSL = wsl;
  # isLinux = !darwin && !isWSL;

  machine = ../machines/${name}.nix;

  user-config = ../users/${user}/${if darwin then "darwin" else "nixos"}.nix;

  systemFunc = if darwin then inputs.darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;

  home-manager =
    if darwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;

in
systemFunc {
  modules = [
      { 
        nixpkgs = {
          hostPlatform = {
            inherit system;
          };
          overlays = overlays; 
          config.allowUnfree = true;
        };
      }

    machine
    user-config
    home-manager.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = (import ../users/${user}/home.nix) {
        isWSL = isWSL;
        inputs = inputs;
      };
    }
    {
      config._module.args = {
        currentSystem = system;
        currentSystemName = name;
        currentSystemUser = user;
        isWSL = isWSL;
        inputs = inputs;
      };
    }
  ];
}
