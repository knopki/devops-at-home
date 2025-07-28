_final: prev:
let
  inherit (prev.lib.strings) compareVersions;
  minVersion = "0.196.0";
  tooOld = compareVersions minVersion prev.zed-editor.version >= 0;
in
{
  zed-editor = if tooOld then prev.nixpkgsUnstable.zed-editor else prev.zed-editor;
}
