{ srcs, lib, stdenv }:
let src = srcs.base16-shell;
in
stdenv.mkDerivation {
  inherit src;
  inherit (src) pname version;

  installPhase = ''
    mkdir -p $out
    cp -a * $out/
  '';

  meta = with lib; {
    description = "Base16 Shell";
    homepage = "https://github.com/chriskempson/base16-shell";
    license = licenses.mit;
    platforms = platforms.all;
    inherit version;
  };
}
