{
  sources,
  lib,
  stdenv,
}:
stdenv.mkDerivation {
  inherit (sources.base16-waybar) pname version src;

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
