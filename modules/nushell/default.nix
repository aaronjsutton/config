{ pkgs, ... }:

{
	wrappers.nushell = {
		basePackage = pkgs.nushell;
		prependFlags = [
			"--env-config"
			./env.nu
			"--config"
			./config.nu
		];
	};
}
