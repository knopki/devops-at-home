final: prev:
let
  inherit (prev.lib.strings) compareVersions;
  minVersion = "0.196.0";
  tooOld = compareVersions minVersion prev.zed-editor.version >= 0;
  zedEditorPkg = if tooOld then prev.nixpkgsUnstable.zed-editor else prev.zed-editor;
in
{
  zed-editor = zedEditorPkg;
  zed-editor-fhs = zedEditorPkg.fhsWithPackages (_ps: [
    # final. prefix - install from the current pkgs
    # ps. prefix - install from the zed-editor's pkgs
    final.bash-language-server
    final.docker-compose-language-service
    final.dockerfile-language-server-nodejs
    # final.eslint
    final.package-version-server
    # final.pyright
    # final.tailwindcss-language-server
    final.taplo
    final.terraform-ls
    # final.vtsls
    # final.yaml-language-server
  ]);
}
