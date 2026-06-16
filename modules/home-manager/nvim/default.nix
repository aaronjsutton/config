{ pkgs }: {
  programs.neovim = {
    enable = true;
    withPython3 = false;
    withRuby = false;
    plugins = with pkgs.vimPlugins; [
      kanagawa-nvim
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
    ];
  };
}
