{ nixpkgsUnstable, sources, ... }:
nixpkgsUnstable.mpvScripts.buildLua {
  inherit (sources.mpv-image-bindings) pname version src;

  installPhase = ''
    mkdir -p $out/share/mpv/scripts
    cp -r scripts/image-bindings.lua $out/share/mpv/scripts/
  '';

  passthru.scriptName = "image-bindings.lua";
}
