{ isWSL, inputs, ...}: 

{ config, lib, pkgs, ... }:

{
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
		awscli2
		delta
		jujutsu
    entr
		nil
    github-cli
    jq
    silver-searcher
    tree
  ];

  programs.home-manager.enable = true;

	xdg = {
		enable = true;
		configFile = {
			"ghostty" = {
				source = ./ghostty;
				recursive = true;
			};
		};
	};

  home.sessionVariables = {
    EDITOR = "nvim";
  };

	programs.fish = {
		enable = true;
	};

	programs.tmux = {
		enable = true;
	};

	programs.jujutsu = {
		enable = true;

		settings = {
			user = {
				name = "Aaron Sutton";
				email = "hey@aaron.as";
			};

			ui = {
				default-command = ["log"];
				pager = "delta";
				diff-formatter = ":git";
			};

			templates = {
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

			signing = {
				behavior = "own";
				backend = "ssh";
				key = "~/.ssh/id_ed25519_signing.pub";
			};
		};
	};

	programs.fzf = {
    colors = {
      bg      = "-1";
      "bg+"   = "#2a2a37";
      fg      = "-1";
      "fg+"   = "#dcd7ba";
      hl      = "#938aa9";
      "hl+"   = "#c4746e";
      header  = "#b6927b";
      info    = "#658594";
      pointer = "#7aa89f";
      marker  = "#7aa89f";
      prompt  = "#c4746e";
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
		userName = "Aaron Sutton";
		userEmail = "hey@aaron.as";
		ignores = [
			".DS_Store"
			".direnv/"
			"*.sw?"
		];
	};

	programs.zoxide = {
		enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
	};

  programs.direnv = {
    enable = true;

    nix-direnv.enable = true;
    enableZshIntegration = true;

    config = {
      global = {
        warn_timeout = "30s";
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
		viAlias = true;
		vimAlias = true;
		package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;

		plugins = with pkgs.vimPlugins; [
			kanagawa-paper-nvim
			nvim-lspconfig
			nvim-ufo
			plenary-nvim
			typescript-tools-nvim
			(nvim-treesitter.withPlugins (
				plugins: with plugins; [
					c
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
					ledger
					lua
					nix
					python
					terraform
					toml
					tsx
					typescript
					yaml
				]
			))
		];
	};

  programs.zsh = {
    enable = true;
		enableCompletion = true;
		initContent = builtins.readFile ./zshrc;
		shellAliases = {
			vz = "fzf --bind 'enter:become(vim {})'";
			ls = "ls --color";
			tree = "tree -C";
		};
		history = {
			save = 8000;
			share = true;
			path = "~/.zsh_history";
		};
  };
}
