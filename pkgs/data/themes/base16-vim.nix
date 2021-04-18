{ srcs, lib, stdenv }:
let src = srcs.base16-vim;
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
    description = "Base16 Vim";
    homepage = "https://github.com/chriskempson/base16-vim";
    license = licenses.mit;
    platforms = platforms.all;
    inherit version;
  };
}
