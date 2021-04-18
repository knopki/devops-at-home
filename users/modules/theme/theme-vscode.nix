{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption mkMerge;
  cfg = config.theme;
in
{
  options.theme.components.vscode.enable = mkEnableOption "Apply theme to VS Code" // {
    default = config.programs.vscode.enable;
  };

  config = mkIf (cfg.enable && cfg.components.vscode.enable) (mkMerge [
    {
      programs.vscode.userSettings = {
        "editor.fontFamily" = "'${cfg.fonts.monospace.family}',monospace";
        "editor.fontLigatures" = true;
        "editor.fontSize" = cfg.fonts.monospace.size + 6;
      };
    }

    (mkIf (cfg.preset == "dracula") {
      programs.vscode = {
        extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
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
