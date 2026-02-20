{ ... }:
{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
{
  programs.home-manager.enable = true;

  home.stateVersion = "25.05";
  home.packages = with pkgs; [
    hut
    just
    nil
    rsync
    silver-searcher
    shadowenv
  ];

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
      "private()" = "subject('private:*')";
    };

    template-aliases = {
      "format_timestamp(timestamp)" = "timestamp.ago()";
    };
  };

  programs.fzf = {
    colors = {
      bg = "-1";
      "bg+" = "#2a2a37";
      fg = "-1";
      "fg+" = "#dcd7ba";
      hl = "#938aa9";
      "hl+" = "#c4746e";
      header = "#b6927b";
      info = "#658594";
      pointer = "#7aa89f";
      marker = "#7aa89f";
      prompt = "#c4746e";
      spinner = "#8ea49e";
    };
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
    color_theme = "Default";
    theme_background = false;
    truecolor = true;
  };
  programs.btop.themes = {
    tokyonight-night = ''
      theme[main_bg]="#1a1b26"
      theme[main_fg]="#c0caf5"
      theme[title]="#c0caf5"
      theme[hi_fg]="#ff9e64"
      theme[selected_bg]="#292e42"
      theme[selected_fg]="#7dcfff"
      theme[proc_misc]="#7dcfff"
      theme[cpu_box]="#3a3a3a"
      theme[mem_box]="#3a3a3a"
      theme[net_box]="#3a3a3a"
      theme[proc_box]="#3a3a3a"
      theme[div_line]="#4e4e4e"
      theme[temp_start]="#9ece6a"
      theme[temp_mid]="#e0af68"
      theme[temp_end]="#f7768e"
      theme[cpu_start]="#9ece6a"
      theme[cpu_mid]="#e0af68"
      theme[cpu_end]="#f7768e"
      theme[free_start]="#9ece6a"
      theme[free_mid]="#e0af68"
      theme[free_end]="#f7768e"
      theme[cached_start]="#9ece6a"
      theme[cached_mid]="#e0af68"
      theme[cached_end]="#f7768e"
      theme[available_start]="#9ece6a"
      theme[available_mid]="#e0af68"
      theme[available_end]="#f7768e"
      theme[used_start]="#9ece6a"
      theme[used_mid]="#e0af68"
      theme[used_end]="#f7768e"
      theme[download_start]="#9ece6a"
      theme[download_mid]="#e0af68"
      theme[download_end]="#f7768e"
      theme[upload_start]="#9ece6a"
      theme[upload_mid]="#e0af68"
      theme[upload_end]="#f7768e"
    '';
  };

  programs.zsh.enable = true;

  programs.neovim.enable = true;
  programs.neovim.plugins =
    # Plugins
    builtins.attrValues {
      inherit (pkgs-unstable.vimPlugins)
        hunk-nvim
        nvim-lspconfig
        tokyonight-nvim
        ;
    }
    # Grammars
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
            ;
        }
      ))
    ];
}
