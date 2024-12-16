{
  nixpkgsUnstable,
  sources,
  ...
}:
nixpkgsUnstable.mpvScripts.buildLua {
  inherit (sources.mpv-align-images) pname version src;

  installPhase = ''
    mkdir -p $out/share/mpv/scripts
    cp -r scripts/align-images.lua $out/share/mpv/scripts/
  '';

  passthru.scriptName = "align-images.lua";
}
