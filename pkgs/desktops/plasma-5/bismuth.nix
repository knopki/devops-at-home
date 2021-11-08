{ srcs, stdenv, lib, pkgs }:
let
  inherit (pkgs.libsForQt5) kcoreaddons kwindowsystem plasma-framework systemsettings;
  src = srcs.bismuth;
in
stdenv.mkDerivation rec {
  inherit src;
  inherit (src) pname version;

  buildInputs = with pkgs; [
    p7zip
    esbuild
    ninja
    cmake
    extra-cmake-modules

    kcoreaddons
    kwindowsystem
    plasma-framework
    systemsettings
    qt5.wrapQtAppsHook
  ];

  dontUseCmakeBuildDir = true;
  cmakeDir = "src/kcm";
  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
    "-B build/kcm"
  ];

  buildPhase = ''
    # Build kwinscript
    mkdir -p "build/kwinscript/contents/code"
    esbuild \
      --bundle "src/kwinscript/index.ts" \
      --outfile="build/kwinscript/contents/code/index.mjs" \
      --format=esm \
      --platform=neutral
    cp -r "src/kwinscript/ui" "build/kwinscript/contents"
    cp "src/kwinscript/metadata.desktop" "build/kwinscript/metadata.desktop"
    substituteInPlace build/kwinscript/metadata.desktop \
      --replace "X-KDE-PluginInfo-Version=\$VER" "X-KDE-PluginInfo-Version=${version}"

    # Create new .kwinscript package
    pushd "build/kwinscript"
    7z a -tzip "bismuth.kwinscript" ./contents ./metadata.desktop
    popd

    # Build KCM
    cmake --build build/kcm
  '';

  installPhase = ''
    runHook preInstall
    cmake --install build/kcm
    plasmapkg2 --type kwinscript --install build/kwinscript/bismuth.kwinscript --packageroot $out/share/kwin/scripts
    install -Dm644 build/kwinscript/metadata.desktop $out/share/kservices5/bismuth.desktop
    runHook postInstall
  '';

  meta = with lib; {
    description = "Addon for KDE Plasma to arrange your windows automatically and switch between them using keyboard shortcuts, like tiling window managers.";
    license = licenses.mit;
    maintainers = with maintainers; [ seqizz ];
    inherit (src.meta) homepage;
    inherit (kwindowsystem.meta) platforms;
  };
}
