{ pkgs, ... }: {

  programs.neovim = {
    enable = true;
    withPython3 = false;
    withRuby = false;
  };

  xdg.configFile."nvim" = {
    source = ./config;
    recursive = true;
  };
}
