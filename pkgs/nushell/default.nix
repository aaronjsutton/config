{
  lib,
  nushell,
  fetchFromGitHub,
  rustPlatform,
}:
nushell.overrideAttrs (
  finalAttrs: _: {
    version = "0.117.0";
    src = fetchFromGitHub {
      owner = "nushell";
      repo = "nushell";
      tag = finalAttrs.version;
      hash = "sha256-+lA9T0Wa/K50qCfyGFdNlEmCZWCeBk8KcxIvDCKk2no=";
    };
    patches = [ ];
    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) pname version src;
      hash = "sha256-0t1ubpyPiXucUlJ+Nwu2u3LZ15GtX6mF2kMy9HkbClw=";
    };
  }
)
