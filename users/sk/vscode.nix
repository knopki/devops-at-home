{ config, lib, pkgs, ... }:
let
  inherit (lib) mkMerge mkIf;
in
{
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      bbenoist.Nix
    ] ++ (pkgs.vscode-utils.extensionsFromVscodeMarketplace []);

    userSettings = {

    };

    keybindings = [
      # {
      #   key = "ctrl+c";
      #   command = "editor.action.clipboardCopyAction";
      #   when = "textInputFocus";
      # }
    ];
  };
}
