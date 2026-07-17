{ ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        name = "Aaron Sutton";
        email = "aaron@aaron.as";
      };
    };
    ignores = [
      ".DS_Store"
      ".direnv/"
      "*.sw?"
    ];
  };

}
