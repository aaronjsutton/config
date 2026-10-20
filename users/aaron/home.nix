{ pkgs, ... }:
{
  imports = [
    ../../modules/home-manager
    ../../modules/home-manager/ghostty
    ../../modules/home-manager/sway
  ];

  home.packages = builtins.attrValues {
    inherit (pkgs)
      coder
      hut
      openssh
      rclone
      ;
  };
}
