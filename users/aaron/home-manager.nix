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

  home.file = {
    ".gitconfig".source = ./gitconfig;
    ".gitignore".source = ./gitignore;
  };

	xdg.configFile = {
		"ghostty/config".text = builtins.readFile ./ghostty;
	};

  home.sessionVariables = {
    EDITOR = "nvim";
  };

	programs.jujutsu = {
		enable = true;
	};

	programs.fzf = {
		enable = true;
		enableZshIntegration = true;
		defaultCommand = "ag -l .";
		defaultOptions = [
			"--height=40%"
			"--layout=reverse"
		];
	};

  xdg.enable = true;

	programs.git = {
		enable = true;
		lfs.enable = true;
	};

	programs.zoxide = {
		enable = true;
    enableZshIntegration = true;
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
			inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.vimPlugins.kanagawa-nvim
			inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.vimPlugins.nvim-lspconfig
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

		initExtra = builtins.readFile ./zshrc;

		plugins = [ ];
  };
}
