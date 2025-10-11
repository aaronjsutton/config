{ pkgs, lib, ... }:

let

  inherit (pkgs) writeTextDir;
  config = writeTextDir "zsh/.zshrc" ''
    			if [[ -o interactive ]]; then
    				source ${./interactive.zsh}
    			fi
    		'';
in
{

  wrappers.zsh-user = {
    basePackage = pkgs.zsh;
    programs.zsh = {
      wrapFlags = [
        "--set"
        "ZDOTDIR"
        (lib.makeSearchPathOutput "out" "zsh" [ config ])
      ];
    };

  };
}
