{ stdenv, fetchurl, pkgs, makeDesktopItem, makeWrapper, lib, ... }:
with lib;
let
  desktopItem = makeDesktopItem {
    name = "WinBox";
    exec = "winbox";
    comment = "Winbox is a small utility that allows administration of MikroTik RouterOS using a fast and simple GUI";
    desktopName = "Winbox";
    categories = "Application;Development;";
    genericName = "Winbox";
  };
in
stdenv.mkDerivation rec {
  name = "winbox-${version}";
  version = "3.19";

  src = fetchurl {
    name = "winbox.exe";
    url = "https://download.mikrotik.com/routeros/winbox/${version}/winbox.exe";
    sha256 = "0npfz8ijkchwcpfhkfvgfgynhq46fyi3wzm39jp2s6jc2sbffk29";
  };

  nativeBuildInputs = with pkgs; [ makeWrapper ];
  buildInputs = with pkgs; [ wine ];

  phases = [ "unpackPhase" "buildPhase" ];

  unpackPhase = ''
    mkdir -p ${name}
    cp $src ${name}/winbox.exe
  '';

  buildPhase = ''
    mkdir -p $out/bin
    cp -r ${name}/winbox.exe $out/bin/
    makeWrapper ${pkgs.wine}/bin/wine $out/bin/winbox \
      --run "export WINEPREFIX=\"\''${XDG_DATA_HOME:-\$HOME/.local/share}/winbox\"" \
      --add-flags $out/bin/winbox.exe

    mkdir -p $out/share/applications
    ln -s ${desktopItem}/share/applications/* $out/share/applications
  '';
}
