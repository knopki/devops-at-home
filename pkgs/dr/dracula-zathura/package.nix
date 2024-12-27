{
  lib,
  stdenv,
  fetchFromGitHub,
  unstableGitUpdater,
}:
stdenv.mkDerivation {
  pname = "dracula-zathura";
  version = "0-unstable-2024-03-09";
  src = fetchFromGitHub {
    owner = "dracula";
    repo = "zathura";
    rev = "d21609b0548eaf45cccc275791dd3cc5c22baa5e";
    fetchSubmodules = false;
    sha256 = "sha256-1bEJYF1T1bk0meySXcww7POCjjzSQpyXdh5YwoZRhRA=";
  };

  installPhase = ''
    mkdir -p $out
    cp -a zathurarc $out/
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "Dracula for Zathura";
    homepage = "https://github.com/dracula/zathura";
    license = licenses.mit;
    platforms = platforms.all;
    inherit version;
  };
}
