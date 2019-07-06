{ config, lib, pkgs, user, ... }:
with lib;
{
  options.local.jsdev.enable = mkEnableOption "JS develper pack";

  config = mkIf config.local.jsdev.enable {
    home.packages = with pkgs; [
      nodejs-10_x
      nodePackages.node2nix
      unstable.postman
      (yarn.override { nodejs = nodejs-10_x; })
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
