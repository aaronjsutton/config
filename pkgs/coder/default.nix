{
  lib,
  fetchurl,
  installShellFiles,
  stdenvNoCC,
  unzip,
}:

let
  inherit (stdenvNoCC.hostPlatform) system;

  version = "2.36.12";
  hash = {
    x86_64-linux = "sha256-F4nE2fGIKjMA/fz7uuLtM975kSjlzXCKP5nAPDT+ymg=";
    x86_64-darwin = "sha256-FwzoDDHsWkD7OkaUK8cFKTIaDuikyBq4sQEl2UWRx9U=";
    aarch64-linux = "sha256-fo3vLwwWCPX0bhlH2svrl3g4P0b2UQvifLtl67cdGW4=";
    aarch64-darwin = "sha256-Jg2uJuPK+8fxy1lnmMREKCVLz39nIM9D6Fkzpax4ESw=";
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "coder";
  inherit version;
  src = fetchurl {
    hash = hash.${system};

    url =
      let
        systemName =
          {
            x86_64-linux = "linux_amd64";
            aarch64-linux = "linux_arm64";
            x86_64-darwin = "darwin_amd64";
            aarch64-darwin = "darwin_arm64";
          }
          .${system};

        ext =
          {
            x86_64-linux = "tar.gz";
            aarch64-linux = "tar.gz";
            x86_64-darwin = "zip";
            aarch64-darwin = "zip";
          }
          .${system};
      in
      "https://github.com/coder/coder/releases/download/v${finalAttrs.version}/coder_${finalAttrs.version}_${systemName}.${ext}";
  };

  nativeBuildInputs = [
    installShellFiles
    unzip
  ];

  unpackPhase = ''
    runHook preUnpack

    case $src in
        *.tar.gz) tar -xz -f "$src" ;;
        *.zip)    unzip      "$src" ;;
    esac

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -D -m755 coder $out/bin/coder

    runHook postInstall
  '';

  # integration tests require network access
  doCheck = false;

  meta = {
    description = "Provision remote development environments via Terraform";
    homepage = "https://coder.com";
    license = lib.licenses.agpl3Only;
    mainProgram = "coder";
  };
})
