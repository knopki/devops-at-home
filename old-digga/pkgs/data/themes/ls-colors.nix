{
  sources,
  lib,
  stdenv,
}:
stdenv.mkDerivation {
  inherit (sources.ls-colors) pname version src;

  installPhase = ''
    mkdir -p $out
    cp -a LS_COLORS $out/
  '';

  meta = with lib; {
    description = "LS_COLORS";
    homepage = "https://github.com/trapd00r/LS_COLORS/";
    license = licenses.mit;
    platforms = platforms.all;
    inherit version;
  };
}
