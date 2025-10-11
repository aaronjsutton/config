{
  pkgs,
  ...
}:
{

  nix = {
    enable = true;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  programs.zsh.enable = true;

  environment.shells = with pkgs; [
    bashInteractive
    zsh
    nushell
  ];

  system.stateVersion = 6;
}
