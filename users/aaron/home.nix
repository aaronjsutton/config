{ ... }:
{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  theme = builtins.fetchTree {
    type = "github";
    owner = "rebelot";
    repo = "kanagawa.nvim";
    rev = "2d9ae006b3b20a156e5eda23aaa65dc49deba10f";
  };
in
{
  programs.home-manager.enable = true;

  programs.nh = {
    enable = true;
    package = pkgs-unstable.nh;
    flake = "$HOME/@config";
  };

  home.stateVersion = "25.05";
  home.packages = builtins.attrValues {
    inherit (pkgs-unstable)
      firefox
      hut
      just
      nil
      rsync
      silver-searcher
      ;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    EZA_CONFIG_DIR = "${config.xdg.configHome}/eza";
    GOPATH = "${config.xdg.cacheHome}/go";
    HOMEBREW_NO_AUTO_UPDATE = 1;
    HOMEBREW_NO_ENV_HINTS = 1;
  };

  xdg.enable = true;
  xdg.configFile = {
    "ghostty" = {
      source = ./config/ghostty;
      recursive = true;
    };
    "ghostty/themes" = {
      source = "${theme}/extras/ghostty";
      recursive = true;
    };
    "nvim" = {
      source = ./config/nvim;
      recursive = true;
    };
    "eza" = {
      source = ./config/eza;
      recursive = true;
    };
  };

  programs.eza.enable = true;
  programs.eza.git = true;
  programs.eza.extraOptions = [
    "--sort=ext"
  ];

  programs.gh.enable = true;
  programs.jq.enable = true;

  programs.tmux.enable = true;
  programs.tmux.extraConfig = builtins.readFile ./config/tmux/tmux.conf;

  programs.jujutsu.enable = true;
  programs.jujutsu.package = pkgs-unstable.jujutsu;
  programs.jujutsu.settings = {
    user.name = "Aaron Sutton";
    user.email = "aaron@aaron.as";

    git.private-commits = "description(glob:'private:*')";

    ui = {
      conflict-marker-style = "git";
      default-command = [ "log" ];
      diff-editor = [
        "nvim"
        "-c"
        "DiffEditor $left $right $output"
      ];
      diff-formatter = ":git";
      merge-editor = [
        "nvim"
        "-d"
        "$left"
        "$base"
        "$right"
        "$output"
      ];
    };

    templates = {
      git_push_bookmark = ''"aaron/push-" ++ change_id.short()'';
      log_node = ''
        coalesce(
          if(!self, "🮀"),
          if(current_working_copy, "◎"),
          if(root, "┴"),
          if(immutable, "●", "○"),
        )
      '';
      op_log_node = ''if(current_operation, "◎", "○")'';
    };

    revet-aliases = {
      "immutable_heads()" = "builtin_immutable_heads() | (trunk().. & ~mine())";
    };

    template-aliases = {
      "format_timestamp(timestamp)" = "timestamp.ago()";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    defaultCommand = "ag -l '.'";
    defaultOptions = [
      "-e"
      "--height=40%"
      "--color=dark"
      "--layout=reverse"
    ];
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  programs.git.settings = {
    user = {
      name = "Aaron Sutton";
      email = "hey@aaron.as";
    };
  };
  programs.git.ignores = [
    ".DS_Store"
    ".direnv/"
    "*.sw?"
  ];

  programs.delta.enable = true;
  programs.delta.enableJujutsuIntegration = true;

  programs.zoxide.enable = true;
  programs.zoxide.enableZshIntegration = true;

  programs.btop.enable = true;
  programs.btop.settings = {
    color_theme = "TTY";
    presets = "cpu:0:default,proc:0:default, net:0:default";
    theme_background = false;
    vim_keys = true;
  };
  programs.zsh.enable = true;

  programs.neovim.enable = true;
  programs.neovim.plugins =
    builtins.attrValues {
      inherit (pkgs-unstable.vimPlugins)
        hunk-nvim
        kanagawa-nvim
        nvim-lspconfig
        ;
    }
    ++ [
      (pkgs-unstable.vimPlugins.nvim-treesitter.withPlugins (
        plugins:
        builtins.attrValues {
          inherit (plugins)
            c
            c-sharp
            css
            csv
            dockerfile
            editorconfig
            elixir
            erlang
            go
            html
            ini
            javascript
            jsdoc
            json
            just
            ledger
            lua
            nix
            python
            razor
            terraform
            toml
            tsx
            typescript
            yaml
            zsh
            ;
        }
      ))
    ];
}
