{
  sources,
  lib,
  stdenv,
}:
stdenv.mkDerivation {
  inherit (sources.dracula-wofi) pname version src;

  installPhase = ''
    mkdir -p $out
    cp -a style.css $out/
  '';

  meta = with lib; {
    description = "Dracula for wofi";
    homepage = "https://github.com/dracula/wofi";
    license = licenses.mit;
    platforms = platforms.all;
    inherit version;
  };
}
