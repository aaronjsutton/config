{
  lib,
  fetchurl,
  installShellFiles,
  makeBinaryWrapper,
  terraform,
  stdenvNoCC,
  unzip,
}:

let
  inherit (stdenvNoCC.hostPlatform) system;

  version = "2.35.7";
  hash = {
    x86_64-linux = "sha256-w3MnVWTWuMk9FomSPs++e1oXkaKu7eEMEpy4f+hTLJo=";
    x86_64-darwin = "sha256-aoTJXBSGqJU+YAxiuosMFKfwZGjwndNG4lsqtHNIBwE=";
    aarch64-linux = "sha256-ZN7mEDVmd+QYXU2Y6e1HN2Prg5MG89jpOhtzRdkPYgs=";
    aarch64-darwin = "sha256-GeaLUwUd4xIsZ2Ry6FRud3MzvNwovumT7tkTehgy9+c=";
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
    makeBinaryWrapper
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

  postInstall = ''
    wrapProgram $out/bin/coder \
      --prefix PATH : ${lib.makeBinPath [ terraform ]}
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
