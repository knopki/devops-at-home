{ config, lib, pkgs, ... }:
let
  inherit (lib) mkDefault;
in
{
  programs.vscode = {
    enable = mkDefault true;
    activationMode = mkDefault "merge";

    # HINT: <nixpkgs>/pkgs/misc/vscode-extensions/update_installed_exts.sh
    extensions = with pkgs.vscode-extensions; [
    #   # ms-kubernetes-tools.vscode-kubernetes-tools
    #   # redhat.vscode-yaml
    #   # vscodevim.vim
    ] ++ (pkgs.vscode-utils.extensionsFromVscodeMarketplace (import ./ext.nix));

    # refer to https://code.visualstudio.com/docs/getstarted/settings#_default-settings
    userSettings = {
      "extensions.autoUpdate" = false;
      "update.mode" = "none";
      "vsicons.dontShowNewVersionMessage" = true;
      "editor.minimap.enabled" = mkDefault false;
      "editor.rulers" = mkDefault [ 80 120 ];

      # "editor.wordWrap" = mkDefault "on";
      # "editor.multiCursorModifier" = mkDefault "alt";
      # "editor.suggestSelection" = mkDefault "first";
      # "explorer.confirmDelete" = mkDefault false;
      # "files.autoSave" = mkDefault "off";
      # "flow.useLSP" = mkDefault true;
      # "flow.useNPMPackagedFlow" = mkDefault true;
      # "git.autofetch" = mkDefault true;
      # "javascript.updateImportsOnFileMove.enabled" = mkDefault "never";
      # "javascript.validate.enable" = mkDefault false;
      # "prettier.trailingComma" = mkDefault "es5";
      # "typescript.disableAutomaticTypeAcquisition" = mkDefault false;
      # "update.mode" = mkDefault "none";
      # "vsicons.dontShowNewVersionMessage" = mkDefault true;
      # "window.titleBarStyle" = mkDefault "custom";
      # "window.zoomLevel" = mkDefault 0;
      # "workbench.startupEditor" = mkDefault "newUntitledFile";
      # "[json]" = {
      #   "editor.defaultFormatter" = mkDefault "esbenp.prettier-vscode";
      # };
      # "[jsonc]" = {
      #   "editor.defaultFormatter" = mkDefault "esbenp.prettier-vscode";
      # };
      # "[javascript]" = {
      #   "editor.defaultFormatter" = mkDefault "esbenp.prettier-vscode";
      # };
      # "[typescript]" = {
      #   "editor.defaultFormatter" = mkDefault "esbenp.prettier-vscode";
      # };
      # "[typescriptreact]" = {
      #   "editor.defaultFormatter" = mkDefault "esbenp.prettier-vscode";
      # };
      # "[yaml]" = {
      #   "editor.defaultFormatter" = mkDefault "esbenp.prettier-vscode";
      # };
    };
  };
}
