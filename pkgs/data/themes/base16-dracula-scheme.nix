{ sources, lib, stdenv }:
stdenv.mkDerivation {
  inherit (sources.base16-dracula-scheme) pname version src;

  installPhase = ''
    mkdir -p $out
    cp -a *.yaml $out/
  '';

  meta = with lib; {
    description = "Dracula for Base16";
    homepage = "https://github.com/dracula/base16-dracula-scheme";
    license = licenses.mit;
    platforms = platforms.all;
    inherit version;
  };
}
