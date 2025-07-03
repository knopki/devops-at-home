final: prev: {
  zed-editor-fhs = prev.nixpkgsUnstable.zed-editor.fhsWithPackages (_ps: [
    # final. prefix - install from the current pkgs
    # ps. prefix - install from the zed-editor's pkgs
    final.bash-language-server
    final.docker-compose-language-service
    final.dockerfile-language-server-nodejs
    final.eslint
    final.pyright
    final.ruff
    final.tailwindcss-language-server
    final.taplo
    final.terraform-ls
    final.vtsls
    final.yaml-language-server
  ]);
}
