{ srcs, lib, stdenv }:
let src = srcs.base16-dracula-scheme;
in
stdenv.mkDerivation {
  inherit src;
  inherit (src) pname version;

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
