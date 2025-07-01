# waiting https://github.com/NixOS/nixpkgs/pull/285657
{
  lib,
  pkgs,
  libsForQt5,
  fetchFromGitHub,
  gitUpdater,
  ...
}:
libsForQt5.mkDerivation rec {
  pname = "aliza";
  version = "1.9.10";
  src = fetchFromGitHub {
    owner = "AlizaMedicalImaging";
    repo = "AlizaMS";
    rev = "v${version}";
    fetchSubmodules = false;
    sha256 = "sha256-6x6QIkhG2Bnf+vl1BJCw+xmSo4SN42Lm1T1MzEoteP8=";
  };

  nativeBuildInputs = with libsForQt5; [
    wrapQtAppsHook
    pkgs.cmake
  ];

  buildInputs = with libsForQt5; [
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

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = with lib; {
    description = "A DICOM Viewer";
    homepage = "https://www.aliza-dicom-viewer.com/";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    mainProgram = "alizams";
  };
}
