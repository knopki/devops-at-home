{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec {
  name = "fira-code-nerd-${version}";
  version = "2.0.0";

  src = fetchurl {
    name = "FiraCode.zip";
    url =
      "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/FiraCode.zip";
    sha256 = "03q7c8pasdxnphvvhp489dd175q442lqf885p8yljq9xpwj4v289";
  };

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "0z53sqm3sxc5nqp2rppr1spjq3d3m3khahzjryh54n2achfah41b";

  nativeBuildInputs = [ unzip ];

  phases = [ "unpackPhase" "installPhase" ];

  unpackPhase = ''
    unzip -j ${src}
  '';

  installPhase = ''
    find . -name '*.otf' -a -not -name '*Windows*' -exec install -m644 -Dt $out/share/fonts/opentype/fira-code-nerd {} \;
  '';
}
