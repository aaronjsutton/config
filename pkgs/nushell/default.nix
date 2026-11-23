{
  lib,
  stdenv,
  stdenvNoCC,
  nushell,
  fetchFromGitHub,
  fetchurl,
  rustPlatform,
}:
let
  version = "0.117.0";

  source = fetchFromGitHub {
    owner = "nushell";
    repo = "nushell";
    tag = version;
    hash = "sha256-+lA9T0Wa/K50qCfyGFdNlEmCZWCeBk8KcxIvDCKk2no=";
  };

  binaries = {
    x86_64-linux = {
      target = "x86_64-unknown-linux-musl";
      hash = "sha256-K4CHhtRK9BFwop+LmhW1ETu26l3akiEJjsqTL4oUmSQ=";
    };
    aarch64-linux = {
      target = "aarch64-unknown-linux-musl";
      hash = "sha256-GZZrlK4Z9S4s8EAsuZhE3foG4jYc9sd7Gy4pq9F+kYg=";
    };
  };

  binary = binaries.${stdenv.hostPlatform.system};
in
if stdenv.hostPlatform.isLinux then
  stdenvNoCC.mkDerivation {
    pname = "nushell";
    inherit version;

    src = fetchurl {
      url = "https://github.com/nushell/nushell/releases/download/${version}/nu-${version}-${binary.target}.tar.gz";
      inherit (binary) hash;
    };

    installPhase = ''
      runHook preInstall

      install -D -m755 nu $out/bin/nu

      runHook postInstall
    '';

    passthru = {
      shellPath = "/bin/nu";
      inherit source;
    };

    meta = nushell.meta // {
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
      platforms = builtins.attrNames binaries;
    };
  }
else
  nushell.overrideAttrs (
    finalAttrs: old: {
      inherit version;
      src = source;
      patches = [ ];
      cargoDeps = rustPlatform.fetchCargoVendor {
        inherit (finalAttrs) pname version src;
        hash = "sha256-0t1ubpyPiXucUlJ+Nwu2u3LZ15GtX6mF2kMy9HkbClw=";
      };
      passthru = old.passthru // {
        inherit source;
      };
    }
  )
