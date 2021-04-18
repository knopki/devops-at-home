{ srcs, lib, stdenv }:
let src = srcs.dracula-alacritty;
in
stdenv.mkDerivation {
  inherit src;
  inherit (src) pname version;

  installPhase = ''
    mkdir -p $out
    cp -a dracula.yml $out/
  '';

  meta = with lib; {
    description = "Dracula for Alacritty";
    homepage = "https://github.com/dracula/alacritty";
    license = licenses.mit;
    platforms = platforms.all;
    inherit version;
  };
}
