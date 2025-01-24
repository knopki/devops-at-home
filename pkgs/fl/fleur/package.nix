{
  pkgs,
  cmake,
  lib,
  stdenv,
  fetchgit,
  gitUpdater,
  libxml2,
  blas,
  lapack,
}:
stdenv.mkDerivation rec {
  pname = "fleur";
  version = "6.2";

  src = fetchgit {
    url = "https://iffgit.fz-juelich.de/fleur/fleur.git";
    rev = "refs/tags/MaX-R${version}";
    hash = "sha256-DnAVsXhhgILPNvU+eS8Ivh3uQfL7h8aIvggqBpZztZo=";
    fetchSubmodules = false;
    leaveDotGit = true;
  };

  passthru.updateScript = gitUpdater { rev-prefix = "MaX-R"; allowedVersions = "6.2"; };

  preConfigure = ''
    bash ./configure.sh -hdf5 false
  '';

  nativeBuildInputs = with pkgs; [
    bash
    cmake
    gfortran
    util-linux
    python3
    git
    doxygen
  ];

  buildInputs = [
    libxml2
    blas
    lapack
  ];


  meta = with lib; {
    description = "The FLEUR project provides a simulation tool for materials properties using density functional theory and related methods.";
    homepage = "https://www.flapw.de/";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
