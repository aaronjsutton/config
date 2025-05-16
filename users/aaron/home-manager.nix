{ isWSL, inputs, ...}: 

{ config, lib, pkgs, ... }:

let
	isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
		awscli2
		delta
		jujutsu
		nodejs
		typescript
    entr
    github-cli
    jq
    silver-searcher
    tree
  ];

  programs.home-manager.enable = true;

	xdg = {
		enable = true;
		configFile = {
			"ghostty/config".text = builtins.readFile ./ghostty;
		};
	};

  home.sessionVariables = {
    EDITOR = "nvim";
  };

	programs.fish = {
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
				diff-formatter = "git";
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
				op_log_node = ''if(current_operation, "@", "○")'';
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
		enable = true;
		enableZshIntegration = true;
    enableFishIntegration = true;
		defaultCommand = "ag -l .";
		defaultOptions = [
			"--height=40%"
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
			kanagawa-nvim
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
		plugins = [ ];
  };
}
