{ pkgs, fetchFromGitHub }:

pkgs.buildVimPlugin rec {
	pname = "vim-lumen";
	version = "2021-02-06";
	src = fetchFromGitHub {
		owner = "vimposter";
		repo = "vim-lumen";
		rev = "698329af06dff684582ec6b3944093d13276345d";
		sha256 = "";
	};
	meta.homepage = "https://github.com/vimposter/vim-lumen/";
}
