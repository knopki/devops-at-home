{
  sources,
  lib,
  stdenv,
}:
stdenv.mkDerivation {
  inherit (sources.dracula-alacritty) pname version src;

  installPhase = ''
    mkdir -p $out
    cp -a dracula.toml $out/
  '';

  meta = with lib; {
    description = "Dracula for Alacritty";
    homepage = "https://github.com/dracula/alacritty";
    license = licenses.mit;
    platforms = platforms.all;
    inherit version;
  };
}
