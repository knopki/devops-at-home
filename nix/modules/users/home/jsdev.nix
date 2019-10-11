{ config, lib, pkgs, user, ... }:
with lib; {
  options.local.jsdev.enable = mkEnableOption "JS develper pack";

  config = mkIf config.local.jsdev.enable {
    home.packages = with pkgs; [
      nodejs
      nodePackages.node2nix
      postman
      yarn
    ];

    home.file = {
      ".npmrc".text = ''
        cache="${config.xdg.cacheHome}/npm"
        prefix="${config.xdg.dataHome}/npm"
      '';
    };

    local.editorconfig = true;
    local.vscode.enable = true;
  };
}
