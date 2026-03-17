{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "dummy-engine";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "tilde-lab";
    repo = "dummy-engine";
    rev = "511956406b56b59528e9067a2f5e45bad0eee829";
    sha256 = "sha256-IhsGyx3nGZJ4bGl1FkzcoseN67vQA7mI25aolvjHZ+w=";
  };

  buildPhase = ''
    make dummyengine
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp dummyengine $out/bin
  '';

  meta = with lib; {
    description = "Sample scientific simulation engine working as a black box.";
    homepage = "https://github.com/tilde-lab/dummy-engine";
    license = licenses.bsd3;
    platforms = [ "x86_64-linux" ];
  };
}
