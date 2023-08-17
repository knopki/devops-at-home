{
  stdenv,
  pkgs,
  lib,
  fetchurl,
  dpkg,
  patchelf,
  gtk3,
  webkitgtk,
  pango,
  cairo,
  gdk-pixbuf,
  libappindicator-gtk3,
  openssl,
  gnome,
}: let
  version = "0.6.0";
  src = fetchurl {
    name = "manta-signer.deb";
    url = "https://github.com/Manta-Network/manta-signer/releases/download/${version}/manta-signer-ubuntu-18.04_${version}_amd64.deb";
    sha256 = "sha256-ShRdlNqQ6fq6HYlpt5yFvrGE5aYOZXDM08EvAVnEsf4=";
  };
  rpath = lib.makeLibraryPath [
    gtk3
    webkitgtk
    pango
    cairo
    gdk-pixbuf
    pkgs.glib
    libappindicator-gtk3
    openssl
    gnome.gnome-keyring
  ];
in
  stdenv.mkDerivation rec {
    inherit version;
    pname = "manta-signer";
    inherit src;
    nativeBuildInputs = [dpkg];
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out
      dpkg -x $src $out
      cp -av $out/usr/* $out
      rm -rf $out/usr
      chmod -R g-w $out
    '';

    postFixup = ''
      # Fix the desktop link
      substituteInPlace $out/share/applications/manta-signer.desktop \
        --replace Exec=manta-signer Exec=$out/bin/manta-signer

      ${patchelf}/bin/patchelf \
        --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath ${rpath} \
        $out/bin/manta-signer
    '';

    meta = with lib; {
      license = licenses.unfree;
      platforms = ["x86_64-linux"];
    };
  }
