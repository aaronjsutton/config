{ lib, pkgs, ... }:
{
  wayland.windowManager.sway = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    config = {
      modifier = "Mod4";
      terminal = "ghostty";
      workspaceOutputAssign = [
        {
          workspace = "1";
          output = "DP-1";
        }
        {
          workspace = "2";
          output = "DP-2";
        }
      ];
      output = {
        "*" = {
          bg = "${./wallpaper.png} fill";
        };
        # Left
        "DP-1" = {
          mode = "3840x2160@59.951Hz";
          scale = "2";
        };
        # Right
        "DP-2" = {
          mode = "2560x1440@120Hz";
          scale = "1";
        };
      };
    };
  };
}
