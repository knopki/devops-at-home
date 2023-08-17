{
  sources,
  lib,
  stdenv,
}:
stdenv.mkDerivation {
  inherit (sources.base16-shell) pname version src;

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
