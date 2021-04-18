{ srcs, lib, stdenv }:
let src = srcs.dracula-zathura;
in
stdenv.mkDerivation {
  inherit src;
  inherit (src) pname version;

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
