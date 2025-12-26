{
  inputs,
  ...
}:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.home-manager.enable = true;

  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    entr
    hut
    just
    nil
    rsync
    silver-searcher
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    GOPATH = "${config.xdg.cacheHome}/go";
    EZA_CONFIG_DIR = "${config.xdg.configHome}/eza";
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
    "--group-directories-first"
  ];

  programs.gh.enable = true;
  programs.jq.enable = true;
  programs.tmux.enable = true;

  programs.jujutsu.enable = true;
  programs.jujutsu.settings  = {
    user.name = "Aaron Sutton";
    user.email = "hey@aaron.as";

    git.private-commits = "description(glob:'private:*')";

    ui = {
      conflict-marker-style = "git";
      default-command = [ "log" ];
      diff-editor = [ "nvim" "-c" "DiffEditor $left $right $output" ];
      diff-formatter = ":git";
      merge-editor = ["nvim" "-d" "$left" "$base" "$right" "-o" "$output"];
      pager = "delta";
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
    lfs ={
      enable = true;
    };
    settings = {
      user = {
        name = "Aaron Sutton";
        email = "hey@aaron.as";
      };
    };
    ignores = [
      ".DS_Store"
      ".direnv/"
      "*.sw?"
    ];
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    config = {
      global = {
        warn_timeout = "2m";
        strict_env = true;
        hide_env_diff = true;
      };
    };
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "TTY";
      theme_background = false;
    };
  };

  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      hunk-nvim
      kanagawa-nvim
      nvim-lspconfig
      telescope-nvim
      (nvim-treesitter.withPlugins (
        plugins: with plugins; [
          c
          c-sharp
          css
          dockerfile
          elixir
          erlang
          go
          html
          javascript
          jsdoc
          json
          jsonc
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
        ]
      ))
      plenary-nvim
    ];
  };

  programs.zsh = {
    autocd = true;
    autosuggestion.enable = false;
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    initContent = builtins.readFile ./init.zsh;

    shellAliases = {
      j = "just";
      vi = "nvim";
      vim = "nvim";
      zource = "source ~/.zshrc";
    };

    history = {
      save = 8000;
      share = true;
      path = "${config.home.homeDirectory}/.zsh_history";
      append = true;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      saveNoDups = true;
      extended = true;
    };
  };
}
