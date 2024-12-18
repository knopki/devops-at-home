# waiting https://github.com/NixOS/nixpkgs/pull/285657
{
  lib,
  pkgs,
  sources,
  ...
}:
pkgs.libsForQt5.mkDerivation {
  inherit (sources.aliza) pname version src;

  nativeBuildInputs = with pkgs.libsForQt5; [
    wrapQtAppsHook
    pkgs.cmake
  ];

  buildInputs = with pkgs.libsForQt5; [
    pkgs.itk
    qtbase
    qtsvg
  ];

  strictDeps = true;

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE:STRING=Release"
    "-DALIZA_QT_VERSION:STRING=5"
    "-DITK_DIR:STRING=${pkgs.itk}"
    "-DMDCM_USE_SYSTEM_ZLIB:BOOL=ON"
  ];

  installPhase = ''
    runHook preInstall
    install -Dm555 ./bin/* -t $out/bin
    runHook postInstall
  '';

  meta = with lib; {
    description = "A DICOM Viewer";
    homepage = "https://www.aliza-dicom-viewer.com/";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    mainProgram = "alizams";
  };
}
