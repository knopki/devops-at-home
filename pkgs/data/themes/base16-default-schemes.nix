{ srcs, lib, stdenv }:
let src = srcs.base16-default-schemes;
in
stdenv.mkDerivation {
  inherit src;
  inherit (src) pname version;

  installPhase = ''
    mkdir -p $out
    cp -a *.yaml $out/
  '';

  meta = with lib; {
    description = "Base16 Default Schemes";
    homepage = "https://github.com/chriskempson/base16-default-schemes";
    license = licenses.mit;
    platforms = platforms.all;
    inherit version;
  };
}
