{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.theme;
in
{
  options.theme.components.vscode.enable = mkEnableOption "Apply theme to VS Code" // { default = cfg.enable; };

  config = mkIf (cfg.enable && cfg.components.vscode.enable) (mkMerge [
    (mkIf (cfg.preset == "dracula") {
      programs.vscode = {
        extensions = with pkgs; pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "theme-dracula";
            publisher = "dracula-theme";
            version = "2.22.3";
            sha256 = "sha256-hp8zTFU66bt/ZK8a7VmQGXU3KTJaeJpRZKTYGLNO0XI=";
          }
        ];
        userSettings = {
          "workbench.colorTheme" = "Dracula";
        };
      };
    })
  ]);
}
