{
  lib,
  stdenv,
  fetchFromGitHub,
  unstableGitUpdater,
  ...
}:
stdenv.mkDerivation {
  pname = "base16-tmux";
  version = "0-unstable-2024-12-15";
  src = fetchFromGitHub {
    owner = "mattdavis90";
    repo = "base16-tmux";
    rev = "20396f130e477512632c37f72590b71f59dbef88";
    fetchSubmodules = false;
    sha256 = "sha256-1y/a9zKXYSq8ygmofr8UGByAehrauTH8QW8jdpYziMI=";
  };

  installPhase = ''
    mkdir -p $out
    cp -a tmuxcolors.tmux $out/
    cp -a colors $out/
    cp -a templates $out/
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "Base16 for TextMate & Sublime Text 2/3";
    homepage = "https://github.com/chriskempson/base16-textmate";
    license = licenses.mit;
    platforms = platforms.all;
    inherit version;
  };
}
