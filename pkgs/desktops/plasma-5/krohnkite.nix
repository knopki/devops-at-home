{ srcs
, stdenv
, lib
, pkgs
}:
let
  inherit (pkgs.libsForQt5) kcoreaddons kwindowsystem plasma-framework systemsettings;
  src = srcs.krohnkite;
in
stdenv.mkDerivation rec {
  inherit src;
  inherit (src) pname version;

  buildInputs = with pkgs; [
    kcoreaddons
    kwindowsystem
    plasma-framework
    systemsettings
    qt5.wrapQtAppsHook
    nodePackages.typescript
    p7zip
  ];

  buildPhase = ''
    make package
  '';

  installPhase = ''
    runHook preInstall
    plasmapkg2 --type kwinscript --install ${pname}-${version}.kwinscript --packageroot $out/share/kwin/scripts
    install -Dm644 ${src}/res/metadata.desktop $out/share/kservices5/krohnkite.desktop
    runHook postInstall
  '';

  meta = with lib; {
    description = "A dynamic tiling extension for KWin";
    license = licenses.mit;
    maintainers = with maintainers; [ seqizz ];
    inherit (src.meta) homepage;
    inherit (kwindowsystem.meta) platforms;
  };
}
