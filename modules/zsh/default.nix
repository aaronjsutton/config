{pkgs, ...}: {

	wrappers.zsh-user = {
		basePackage = pkgs.zsh;
	};
}
