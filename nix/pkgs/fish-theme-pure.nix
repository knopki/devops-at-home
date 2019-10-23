{ stdenv, fetchFromGitHub }:
let
  sources = import ../sources.nix;
in
stdenv.mkDerivation rec {
  name = "fish-theme-pure-${version}";
  version = sources.fish-theme-pure.version;
  src = sources.fish-theme-pure;
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/share/fish
    cp -r functions $out/share/fish/vendor_functions.d
    cp -r conf.d $out/conf.d
    cp fish_greeting.fish fish_mode_prompt.fish fish_prompt.fish fish_right_prompt.fish fish_title.fish $out
  '';
}
