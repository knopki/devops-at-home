{
  lib,
  stdenv,
  fetchFromGitHub,
  unstableGitUpdater,
}:
stdenv.mkDerivation {
  pname = "ls-colors";
  version = "0-unstable-2024-12-20";
  src = fetchFromGitHub {
    owner = "trapd00r";
    repo = "LS_COLORS";
    rev = "81e2ebcdc2ed815d17db962055645ccf2125560c";
    fetchSubmodules = false;
    sha256 = "sha256-ePs7UlgQqh3ptRXUNlY/BDa/1aH9q3dGa3h0or/e6Kk=";
  };

  installPhase = ''
    mkdir -p $out
    cp -a LS_COLORS $out/
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "LS_COLORS";
    homepage = "https://github.com/trapd00r/LS_COLORS/";
    license = licenses.mit;
    platforms = platforms.all;
    inherit version;
  };
}
