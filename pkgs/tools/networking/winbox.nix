{ stdenv, fetchurl, pkgs, makeDesktopItem, makeWrapper, lib, ... }:
let
  inherit (stdenv) targetPlatform;
  binaryName = if targetPlatform.isx86_64 then "winbox64.exe" else "winbox.exe";
  version = "3.32";
  src = fetchurl {
    url = "https://download.mikrotik.com/routeros/winbox/${version}/${binaryName}";
    sha256 =
      if targetPlatform.isx86_64
      then "1gf0zdn4ahfp08fn5w0nzigwldl3bjqcj2f08rcvyn0mbwar4znn"
      else "18rmbnv7iwba19sfh4q4wfwh385snrmpvs6dyad2s9rv7vh2nch7";
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
  wineBinary =
    if targetPlatform.isx86_64
    then "${pkgs.wine64}/bin/wine64" else "${pkgs.wine}/bin/wine";
in
stdenv.mkDerivation rec {
  inherit meta src version;
  name = "winbox-bin-${version}";
  preferLocalBuild = true;
  nativeBuildInputs = with pkgs; [ makeWrapper ];

  phases = [ "unpackPhase" "buildPhase" ];

  unpackPhase = ''
    mkdir -p ${name}
    cp $src ${name}/${binaryName}
  '';

  buildPhase = ''
    mkdir -p $out/bin
    cp -r ${name}/${binaryName} $out/bin/
    makeWrapper ${wineBinary} $out/bin/winbox \
      --run "export WINEPREFIX=\"\''${XDG_DATA_HOME:-\$HOME/.local/share}/winbox${if targetPlatform.isx86_64 then "64" else ""}\"" \
      --add-flags $out/bin/${binaryName}

    mkdir -p $out/share/applications
    ln -s ${desktopItem}/share/applications/* $out/share/applications
  '';
}
