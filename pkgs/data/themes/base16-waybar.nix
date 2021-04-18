{ srcs, lib, stdenv }:
let src = srcs.base16-waybar;
in
stdenv.mkDerivation {
  inherit src;
  inherit (src) pname version;

  installPhase = ''
    mkdir -p $out
    cp -a colors $out/
    cp -a templates $out/
  '';

  meta = with lib; {
    description = "Base16-waybar";
    homepage = "https://github.com/mnussbaum/base16-waybar";
    license = licenses.mit;
    platforms = platforms.all;
    inherit version;
  };
}
