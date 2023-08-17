{
  appimageTools,
  pkgs,
  sources,
  ...
}:
appimageTools.wrapType2 rec {
  inherit (sources.ledger-live-desktop) pname src version;
  inherit (pkgs.ledger-live-desktop) meta;
  extraInstallCommands = let
    fs = pkgs.appimageTools.extractType2 {inherit pname version src;};
  in ''
    mv $out/bin/${pname}-${version} $out/bin/${pname}
    install -m 444 -D ${fs}/ledger-live-desktop.desktop $out/share/applications/ledger-live-desktop.desktop
    install -m 444 -D ${fs}/ledger-live-desktop.png $out/share/icons/hicolor/1024x1024/apps/ledger-live-desktop.png
    ${pkgs.imagemagick}/bin/convert ${fs}/ledger-live-desktop.png -resize 512x512 ledger-live-desktop_512.png
    install -m 444 -D ledger-live-desktop_512.png $out/share/icons/hicolor/512x512/apps/ledger-live-desktop.png
    substituteInPlace $out/share/applications/ledger-live-desktop.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'
  '';
}
