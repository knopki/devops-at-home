{ srcs, lib, stdenv }:
let src = srcs.dracula-wofi;
in
stdenv.mkDerivation {
  inherit src;
  inherit (src) pname version;

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
