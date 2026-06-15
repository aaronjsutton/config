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

  home = {
    stateVersion = "25.05";
    packages = builtins.attrValues {
      inherit (pkgs-unstable)
      hut
      just
      nil
      nodejs
      openssh
      ripgrep
      rsync
      zoxide
      ;
    };
    sessionVariables = {
      EDITOR = "nvim";
      EZA_CONFIG_DIR = "${config.xdg.configHome}/eza";
      FZF_DEFAULT_COMMAND = "rg -l .";
      FZF_DEFAULT_OPTS = "--height=10% --layout=reverse";
      GOPATH = "${config.xdg.cacheHome}/go";
      HOMEBREW_NO_AUTO_UPDATE = "1";
      HOMEBREW_NO_ENV_HINTS = "1";
    };
  };

  xdg = {
    enable = true;
    configFile = {
      "nvim" = {
        source = ./config/nvim;
        recursive = true;
      };
      "eza" = {
        source = ./config/eza;
        recursive = true;
      };
      "ghostty" = {
        source = ./config/ghostty;
        recursive = true;
      };
      "ghostty/themes/light" = {
        source = "${theme}/extras/ghostty/kanagawa-lotus";
      };
      "ghostty/themes/dark" = {
        source = "${theme}/extras/ghostty/kanagawa-dragon";
      };
    };
  };

  programs.nh = {
    enable = true;
    package = pkgs-unstable.nh;
    flake = "$HOME/@config";
  };

  programs.eza = {
    enable = true;
    git = true;
    extraOptions = [
      "--sort=ext"
    ];
  };

  programs.gh.enable = true;
  programs.jq.enable = true;

  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ./config/tmux/tmux.conf;
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      aliases = {
        a = [
          "log"
          "-r"
          "all()"
        ];
        g = [ "git" ];
        sync = [ "git" "fetch" "--all-remotes" ];
      };

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
  };

  programs.fzf = {
    enable = true;
  };

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

  programs.delta = {
    enable = true;
    enableJujutsuIntegration = true;
  };

  programs.btop = {
    enable = true;
    package = pkgs-unstable.btop;
    settings = {
      color_theme = "TTY";
      presets = "cpu:0:default,proc:0:default,net:0:default";
      theme_background = false;
      vim_keys = true;
    };
  };

  programs.neovim = {
    enable = true;
    withPython3 = false;
    withRuby = false;
    plugins = with pkgs-unstable.vimPlugins; [
      kanagawa-nvim
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
    ];
  };
}
