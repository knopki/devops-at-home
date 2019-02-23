{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "fish-theme-pure-${version}";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "rafaelrinaldi";
    repo = "pure";
    rev = "v2.1.1";
    sha256 = "1zdag12dyl7h6f046l411vmysw8fiim49zx5x4bh66vld8nj0h7k";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/fish
    cp -r functions $out/share/fish/vendor_functions.d
    cp -r conf.d $out/conf.d
    cp fish_greeting.fish fish_mode_prompt.fish fish_prompt.fish fish_right_prompt.fish fish_title.fish $out
  '';
}
