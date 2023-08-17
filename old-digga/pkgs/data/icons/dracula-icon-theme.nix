{
  stdenv,
  lib,
  fetchzip,
  gtk3,
  gnome3,
  gnome-icon-theme,
  hicolor-icon-theme,
}:
stdenv.mkDerivation rec {
  pname = "dracula-icon-theme";
  version = "20210108";

  src = fetchzip {
    # url from https://draculatheme.com/gtk
    url = "https://github.com/dracula/gtk/files/5214870/Dracula.zip";
    name = "icons.zip";
    sha256 = "sha256-rcSKlgI3bxdh4INdebijKElqbmAfTwO+oEt6M2D1ls0=";
    extraPostFetch = "chmod go-w $out";
  };

  nativeBuildInputs = [gtk3];

  propagatedBuildInputs = [
    gnome3.adwaita-icon-theme
    gnome-icon-theme
    hicolor-icon-theme
  ];

  dontDropIconThemeCache = true;

  installPhase = ''
    mkdir -p $out/share/icons/Dracula
    mv * $out/share/icons/Dracula
    gtk-update-icon-cache $out/share/icons/Dracula
  '';

  meta = with lib; {
    description = "Dracula icon theme";
    homepage = "https://draculatheme.com/gtk";
    license = licenses.lgpl3;
  };
}
