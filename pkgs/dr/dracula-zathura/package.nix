{
  sources,
  lib,
  stdenv,
}:
stdenv.mkDerivation {
  inherit (sources.dracula-zathura) pname version src;

  installPhase = ''
    mkdir -p $out
    cp -a zathurarc $out/
  '';

  meta = with lib; {
    description = "Dracula for Zathura";
    homepage = "https://github.com/dracula/zathura";
    license = licenses.mit;
    platforms = platforms.all;
    inherit version;
  };
}
