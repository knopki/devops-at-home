{
  lib,
  stdenv,
  sources,
}:
stdenv.mkDerivation {
  inherit (sources.base16-default-schemes) pname version src;

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
