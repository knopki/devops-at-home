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
            version = "2.1.8";
            sha256 = "18yw1c2yylwbvg5cfqfw8h1r2nk9vlixh0im2px8lr7lw0airl28";
          }
          {
            name = "prettier-vscode";
            publisher = "esbenp";
            version = "5.1.3";
            sha256 = "03i66vxvlyb3msg7b8jy9x7fpxyph0kcgr9gpwrzbqj5s7vc32sr";
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
            version = "0.26.1";
            sha256 = "0vd2hr2vzjm9b82zhl0b49vxsz6gq3nnh5v80y4hbbd9qk17yxv5";
          }
          {
            name = "indent-rainbow";
            publisher = "oderwat";
            version = "7.4.0";
            sha256 = "1xnsdwrcx24vlbpd2igjaqlk3ck5d6jzcfmxaisrgk7sac1aa81p";
          }
          {
            name = "vscode-yaml";
            publisher = "redhat";
            version = "0.10.0";
            sha256 = "13ff3syl22z810adz0hwimfcyl6irycmw8f3nlscaq5w2fnk8znq";
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
            version = "101.9.3";
            sha256 = "10hdawdm5hwjpxr8lp7bh1b1pfkwmhmwj100rmqdjgdryq6fb4fb";
          }
          {
            name = "vscodeintellicode";
            publisher = "VisualStudioExptTeam";
            version = "1.2.10";
            sha256 = "1l980w4r18613hzwvqgnzm9csi72r9ngyzl94p39rllpiqy7xrhi";
          }
          {
            name = "vscode-icons";
            publisher = "vscode-icons-team";
            version = "10.2.0";
            sha256 = "13s5jrlj2czwh01bi4dds03hd9hpqk1gs9h0gja0g15d0j4kh39c";
          }
        ];

      userSettings = {
        "debug.inlineValues" = true;
        "editor.fontFamily" = "'FiraCode Nerd Font',monospace";
        "editor.fontLigatures" = true;
        "editor.fontSize" = 14;
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
