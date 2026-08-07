{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  gcc, # libstdc++
  zlib,
  alsa-lib,
  xdotool, # libxdo
  libx11,
  libxtst,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "openhuman-core";
  version = "0.63.9";

  src =
    let
      inherit (finalAttrs) version;
      arch =
        if stdenvNoCC.hostPlatform.isx86_64 then
          "x86_64"
        else if stdenvNoCC.hostPlatform.isAarch64 then
          "aarch64"
        else
          throw "unsupported arch ${stdenvNoCC.hostPlatform.system}";
    in
    fetchurl {
      url = "https://github.com/tinyhumansai/openhuman/releases/download/v${version}/openhuman-core-${version}-${arch}-unknown-linux-gnu.tar.gz";
      hash =
        if stdenvNoCC.hostPlatform.isx86_64 then
          "sha256-cU+HC73O7DLhKGYil05NC4mFBiKIgNgIrjaNnOXx51s="
        else
          "sha256-F5WE2Qe2v094j9jNybag/5WhLn2SbEyyFxMaKtA0VkI=";
    };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    gcc.cc.lib
    zlib
    alsa-lib
    xdotool
    libx11
    libxtst
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm555 openhuman-core $out/bin/openhuman
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "OpenHuman core CLI — local-first memory, agent orchestration, deep research (headless)";
    homepage = "https://github.com/tinyhumansai/openhuman";
    changelog = "https://github.com/tinyhumansai/openhuman/releases/tag/v${finalAttrs.version}";
    license = licenses.gpl3Only;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "openhuman";
  };
})
