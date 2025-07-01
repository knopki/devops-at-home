{
  lib,
  stdenv,
  fetchFromGitHub,
  unstableGitUpdater,
}:
stdenv.mkDerivation {
  pname = "ls-colors";
  version = "0-unstable-2025-06-06";
  src = fetchFromGitHub {
    owner = "trapd00r";
    repo = "LS_COLORS";
    rev = "810ce8cac886ac50e75d84fb438b549a1f9478ee";
    fetchSubmodules = false;
    sha256 = "sha256-MMzNknuELhpSkvcPgCL2Pp5A6DZrLajkz8qLphSNbjY=";
  };

  installPhase = ''
    mkdir -p $out
    cp -a LS_COLORS lscolors.csh lscolors.sh $out/
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
