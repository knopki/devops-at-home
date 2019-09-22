{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "fish-kubectl-completions-${version}";
  version = "0.0.0";

  src = fetchFromGitHub (
    builtins.fromJSON
      (builtins.readFile ./versions.json)
  ).fish-kubectl-completions;

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/fish/vendor_completions.d
    cp completions/kubectl.fish $out/share/fish/vendor_completions.d
  '';
}
