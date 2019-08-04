{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "fish-theme-pure-${version}";
  version = "2.1.8";

  src = fetchFromGitHub
    (builtins.fromJSON (builtins.readFile ./versions.json)).fish-theme-pure;

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/fish
    cp -r functions $out/share/fish/vendor_functions.d
    cp -r conf.d $out/conf.d
    cp fish_greeting.fish fish_mode_prompt.fish fish_prompt.fish fish_right_prompt.fish fish_title.fish $out
  '';
}
