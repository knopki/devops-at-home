{
  appimageTools,
  pkgs,
  sources,
  makeWrapper,
  imagemagick,
  ...
}:
let
  appimageContents = appimageTools.extractType2 {
    inherit (sources.ledger-live-desktop) pname src version;
  };
in
appimageTools.wrapType2 rec {
  inherit (sources.ledger-live-desktop) pname src version;
  inherit (pkgs.ledger-live-desktop) meta;
  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/ledger-live-desktop.desktop $out/share/applications/ledger-live-desktop.desktop
    install -m 444 -D ${appimageContents}/ledger-live-desktop.png $out/share/icons/hicolor/1024x1024/apps/ledger-live-desktop.png
    ${imagemagick}/bin/convert ${appimageContents}/ledger-live-desktop.png -resize 512x512 ledger-live-desktop_512.png
    install -m 444 -D ledger-live-desktop_512.png $out/share/icons/hicolor/512x512/apps/ledger-live-desktop.png

    source "${makeWrapper}/nix-support/setup-hook"
    wrapProgram "$out/bin/${pname}" \
       --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-features=WaylandWindowDecorations --enable-wayland-ime}}"

    substituteInPlace $out/share/applications/ledger-live-desktop.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'
  '';
}
