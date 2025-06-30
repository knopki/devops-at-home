{
  # pkgs,
  # cmake,
  lib,
  stdenv,
  fetchFromGitHub,
  unstableGitUpdater,
# libxml2,
# blas,
# lapack,
}:
stdenv.mkDerivation rec {
  pname = "dummy-engine";
  version = "0-unstable-0000-00-00";

  src = fetchFromGitHub {
    owner = "tilde-lab";
    repo = "dummy-engine";
    rev = "3c54aa69d7053d4c82d19872a740022367bacb90";
    sha256 = "sha256-OfygeiqSpePHSlq4l959OqDV83Q6vNVK08Mqewg9T3o=";
  };

  passthru.updateScript = unstableGitUpdater { };

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
