{ stdenv, fetchurl, pkgs, makeDesktopItem, makeWrapper, lib, ... }:
let
  version = "3.20";
  src = fetchurl {
    url = "https://download.mikrotik.com/routeros/winbox/${version}/winbox.exe";
    sha256 = "1n2fxdqyslw5l19yajxfmvyacbm7jcc5z2qy4g110ir86mw3kpf2";
  };
  description = "Winbox is a small utility that allows administration of MikroTik RouterOS using a fast and simple GUI";
  meta = {
    inherit description;
    longDescription = description;
    homepage = https://mikrotik.com;
    license = {
      fullName = "MIKROTIKLS MIKROTIK SOFTWARE END-USER LICENCE AGREEMENT";
      url = https://mikrotik.com/downloadterms.html;
      free = false;
    };
    maintainers = [ ];
    platforms = [ "i686-linux" "x86_64-linux" ];
  };
  desktopItem = makeDesktopItem {
    name = "WinBox";
    exec = "winbox";
    comment = meta.description;
    desktopName = "Winbox";
    categories = "Application;Development;";
    genericName = "Winbox";
  };
in
stdenv.mkDerivation rec {
  inherit meta src version;
  name = "winbox-bin-${version}";
  preferLocalBuild = true;
  nativeBuildInputs = with pkgs; [ makeWrapper ];

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
