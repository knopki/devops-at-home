{ config, lib, pkgs, ... }:
let
  inherit (lib) mkDefault;
in
{
  programs.vscode = {
    enable = mkDefault true;
    activationMode = mkDefault "merge";

    # HINT: <nixpkgs>/pkgs/misc/vscode-extensions/update_installed_exts.sh
    extensions = with pkgs.vscode-extensions; [ ];

    # refer to https://code.visualstudio.com/docs/getstarted/settings#_default-settings
    userSettings = {
      "extensions.autoUpdate" = false;
      "update.mode" = "none";
      "vsicons.dontShowNewVersionMessage" = true;

      "editor.minimap.enabled" = mkDefault false;
      "editor.rulers" = mkDefault [ 80 120 ];
    };

    keybindings = [];
  };
}
