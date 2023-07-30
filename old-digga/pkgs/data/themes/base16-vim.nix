{ sources, lib, stdenv }:
stdenv.mkDerivation {
  inherit (sources.base16-vim) pname version src;

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
