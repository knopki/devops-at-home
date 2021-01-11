{ config, lib, pkgs, ... }:
with lib;
{
  options.knopki.vscode.enable = mkEnableOption "VSCode config";

  config = mkIf config.knopki.vscode.enable {
    programs.vscode = {
      enable = true;
      # HINT: <nixpkgs>/pkgs/misc/vscode-extensions/update_installed_exts.sh
      extensions = with pkgs;
        pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "bracket-pair-colorizer";
            publisher = "CoenraadS";
            version = "1.0.61";
            sha256 = "0r3bfp8kvhf9zpbiil7acx7zain26grk133f0r0syxqgml12i652";
          }
          {
            name = "vscode-eslint";
            publisher = "dbaeumer";
            version = "2.1.14";
            sha256 = "113w2iis4zi4z3sqc3vd2apyrh52hbh2gvmxjr5yvjpmrsksclbd";
          }
          {
            name = "prettier-vscode";
            publisher = "esbenp";
            version = "5.8.0";
            sha256 = "0h7wc4pffyq1i8vpj4a5az02g2x04y7y1chilmcfmzg2w42xpby7";
          }
          {
            name = "vscode-firefox-debug";
            publisher = "firefox-devtools";
            version = "2.9.1";
            sha256 = "1xr1z96kd2lcamklc0x4sv0if8n78cr0ara5lmc7bh5afy0h085g";
          }
          {
            name = "flow-for-vscode";
            publisher = "flowtype";
            version = "1.5.0";
            sha256 = "0firvhcnd4mvb19r51pw4q6fadsnb8l0hdfin292s4kvcjkqcdc5";
          }
          {
            name = "vscode-kubernetes-tools";
            publisher = "ms-kubernetes-tools";
            version = "1.2.1";
            sha256 = "071p27xcq77vbpnmb83pjsnng7h97q4gai0k6qgwg3ygv086hpf4";
          }
          {
            name = "vetur";
            publisher = "octref";
            version = "0.31.3";
            sha256 = "02fhmmi08335ky4v5ayf4ra0gzrkrpjghrjpd77bxjikjh98wkdz";
          }
          {
            name = "indent-rainbow";
            publisher = "oderwat";
            version = "7.5.0";
            sha256 = "0zm1m46gm4hl56y9555h3rg8xznygmxb5qlq9yl5wxdjsjcia4qk";
          }
          {
            name = "vscode-yaml";
            publisher = "redhat";
            version = "0.13.0";
            sha256 = "046kdk73a5xbrwq16ff0l64271c6q6ygjvxaph58z29gyiszfkig";
          }
          {
            name = "vscode-stylelint";
            publisher = "stylelint";
            version = "0.85.0";
            sha256 = "14nb3rr128kl7n1c70bbmi1v127dlj64qi37qz300fkdzgpl88mn";
          }
          {
            name = "svelte-vscode";
            publisher = "svelte";
            version = "103.0.0";
            sha256 = "0bkcylg9v5v9y1ckhzmz04mwk7irmv0man2c0s68ysh8abxlbyaa";
          }
          {
            name = "vscode-icons";
            publisher = "vscode-icons-team";
            version = "11.1.0";
            sha256 = "1xrz9f0nckx29wxpmlj1dqqiaal3002xwgzz5p9iss119sxgpwrx";
          }
        ];

      userSettings = {
        "debug.inlineValues" = true;
        "editor.minimap.enabled" = false;
        "editor.minimap.renderCharacters" = false;
        "editor.multiCursorModifier" = "alt";
        "editor.rulers" = [ 80 120 ];
        "editor.suggestSelection" = "first";
        "editor.wordWrap" = "on";
        "explorer.confirmDelete" = false;
        "extensions.autoUpdate" = false;
        "files.autoSave" = "off";
        "flow.useNPMPackagedFlow" = true;
        "flow.useLSP" = true;
        "git.autofetch" = true;
        "javascript.updateImportsOnFileMove.enabled" = "never";
        "javascript.validate.enable" = false;
        "prettier.trailingComma" = "es5";
        "typescript.disableAutomaticTypeAcquisition" = false;
        "update.mode" = "none";
        "vsicons.dontShowNewVersionMessage" = true;
        "window.titleBarStyle" = "custom";
        "window.zoomLevel" = 0;
        "workbench.startupEditor" = "newUntitledFile";
        "[json]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
        "[jsonc]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
        "[javascript]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[typescript]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[typescriptreact]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[yaml]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
      };
    };
  };
}
