{ ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      inherit (import ../common) user;
    };
    ignores = [
      ".DS_Store"
      ".direnv/"
      "*.sw?"
    ];
  };

}
