{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkMerge mkIf;
in {
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions;
      [
        bbenoist.nix
        # ms-kubernetes-tools.vscode-kubernetes-tools
        # redhat.vscode-yaml
        # vscodevim.vim
      ]
      ++ (pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        # {
        #   name = "bracket-pair-colorizer";
        #   publisher = "CoenraadS";
        #   version = "1.0.61";
        #   sha256 = "0r3bfp8kvhf9zpbiil7acx7zain26grk133f0r0syxqgml12i652";
        # }
        # {
        #   name = "vscode-eslint";
        #   publisher = "dbaeumer";
        #   version = "2.1.14";
        #   sha256 = "113w2iis4zi4z3sqc3vd2apyrh52hbh2gvmxjr5yvjpmrsksclbd";
        # }
        # {
        #   name = "prettier-vscode";
        #   publisher = "esbenp";
        #   version = "5.8.0";
        #   sha256 = "0h7wc4pffyq1i8vpj4a5az02g2x04y7y1chilmcfmzg2w42xpby7";
        # }
        # {
        #   name = "vscode-firefox-debug";
        #   publisher = "firefox-devtools";
        #   version = "2.9.1";
        #   sha256 = "1xr1z96kd2lcamklc0x4sv0if8n78cr0ara5lmc7bh5afy0h085g";
        # }
        # {
        #   name = "flow-for-vscode";
        #   publisher = "flowtype";
        #   version = "1.5.0";
        #   sha256 = "0firvhcnd4mvb19r51pw4q6fadsnb8l0hdfin292s4kvcjkqcdc5";
        # }
        # {
        #   name = "vetur";
        #   publisher = "octref";
        #   version = "0.31.3";
        #   sha256 = "02fhmmi08335ky4v5ayf4ra0gzrkrpjghrjpd77bxjikjh98wkdz";
        # }
        # {
        #   name = "indent-rainbow";
        #   publisher = "oderwat";
        #   version = "7.5.0";
        #   sha256 = "0zm1m46gm4hl56y9555h3rg8xznygmxb5qlq9yl5wxdjsjcia4qk";
        # }
        # {
        #   name = "vscode-stylelint";
        #   publisher = "stylelint";
        #   version = "0.85.0";
        #   sha256 = "14nb3rr128kl7n1c70bbmi1v127dlj64qi37qz300fkdzgpl88mn";
        # }
        # {
        #   name = "svelte-vscode";
        #   publisher = "svelte";
        #   version = "103.0.0";
        #   sha256 = "0bkcylg9v5v9y1ckhzmz04mwk7irmv0man2c0s68ysh8abxlbyaa";
        # }
        # {
        #   name = "vscode-icons";
        #   publisher = "vscode-icons-team";
        #   version = "11.1.0";
        #   sha256 = "1xrz9f0nckx29wxpmlj1dqqiaal3002xwgzz5p9iss119sxgpwrx";
        # }
      ]);

    userSettings = {
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

    keybindings = [
      # {
      #   key = "ctrl+c";
      #   command = "editor.action.clipboardCopyAction";
      #   when = "textInputFocus";
      # }
    ];
  };
}
