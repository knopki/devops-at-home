{ sources, lib, stdenv }:
stdenv.mkDerivation {
  inherit (sources.base16-textmate) pname version src;

  installPhase = ''
    mkdir -p $out
    cp -a Themes $out/
    cp -a templates $out/
  '';

  meta = with lib; {
    description = "Base16 for TextMate & Sublime Text 2/3";
    homepage = "https://github.com/chriskempson/base16-textmate";
    license = licenses.mit;
    platforms = platforms.all;
    inherit version;
  };
}
