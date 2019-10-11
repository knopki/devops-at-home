{ config, lib, pkgs, user, ... }:
with lib; {
  options.local.vscode.enable =
    mkEnableOption "VSCode with config and workspaces";

  config = mkIf config.local.vscode.enable {
    home.file = {
      "${config.home.homeDirectory}/dev/xodio/xod.code-workspace".text =
        builtins.toJSON {
          folders = [
            {
              name = "xod";
              path = "xod";
            }
            {
              name = "docs";
              path = "xod-docs";
            }
            {
              name = "backend";
              path = "services.xod.io";
            }
          ];
          settings = {};
          extensions = {
            recommendations = [
              "bibhasdn.unique-lines"
              "christian-kohler.path-intellisense"
              "codezombiech.gitignore"
              "CoenraadS.bracket-pair-colorizer"
              "DeepInThought.vscode-shell-snippets"
              "eamodio.gitlens"
              "EditorConfig.EditorConfig"
              "esbenp.prettier-vscode"
              "foxundermoon.shell-format"
              "GitHub.vscode-pull-request-github"
              "ms-kubernetes-tools.vscode-kubernetes-tools"
              "ms-vscode.PowerShell"
              "oderwat.indent-rainbow"
              "PeterJausovec.vscode-docker"
              "redhat.vscode-yaml"
              "wayou.vscode-todo-highlight"
              "xabikos.JavaScriptSnippets"
              "xabikos.ReactSnippets"
              "yzhang.markdown-all-in-one"
            ];
          };
        };
    };

    programs.vscode = {
      enable = true;
      extensions = with pkgs;
        [
          vscode-extensions.bbenoist.Nix
          vscode-extensions.ms-python.python
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "vscode-ansible";
            publisher = "vscoss";
            version = "0.5.2";
            sha256 = "0r1aqfc969354j8b1k9xsg682fynbk4xjp196f3yknlwj66jnpwx";
          }
          {
            name = "bracket-pair-colorizer";
            publisher = "CoenraadS";
            version = "1.0.61";
            sha256 = "0r3bfp8kvhf9zpbiil7acx7zain26grk133f0r0syxqgml12i652";
          }
          {
            name = "gitlens";
            publisher = "eamodio";
            version = "9.9.3";
            sha256 = "04rns3bwc9cav5rdk5bjm6m0lzjqpm9x99539bhk319l83ksffyv";
          }
          {
            name = "indent-rainbow";
            publisher = "oderwat";
            version = "7.4.0";
            sha256 = "1xnsdwrcx24vlbpd2igjaqlk3ck5d6jzcfmxaisrgk7sac1aa81p";
          }
          {
            name = "vscode-kubernetes-tools";
            publisher = "ms-kubernetes-tools";
            version = "1.0.2";
            sha256 = "1xf96llx8nn69bpdl4px7ql7skzyajqk8fljp9z87pcs41qfa8a3";
          }
          {
            name = "vscode-todo-highlight";
            publisher = "wayou";
            version = "1.0.4";
            sha256 = "0s925rb668spv602x6g7sld2cs5ayiq7273963v9prvgsr0drlrr";
          }
          {
            name = "unique-lines";
            publisher = "bibhasdn";
            version = "1.0.0";
            sha256 = "1x0lkdvc0247bms200nn2z5m7qaq9lg96ppbgk6lg3mgmxknjijv";
          }
          {
            name = "vscode-icons";
            publisher = "vscode-icons-team";
            version = "9.2.0";
            sha256 = "0cyyhfm18nbgnp17ixqf3b4v658afxi56xl6rgh0zq411pb36zf8";
          }
          {
            name = "vscode-yaml";
            publisher = "redhat";
            version = "0.4.1";
            sha256 = "01qh61x4hgsqb6l5rcq60w87g8hm0mv9d5gkcdhjdikgqjxfsx6z";
          }
          {
            name = "vscode-eslint";
            publisher = "dbaeumer";
            version = "1.9.0";
            sha256 = "1lr25v236cz8kbgbgqj6izh3f4nwp9cxygpa0zzfvfrg8gg0x49w";
          }
          {
            name = "prettier-vscode";
            publisher = "esbenp";
            version = "1.9.0";
            sha256 = "1an9dlkicj1s0ffy9l9jdvzpcdl0slvln9k05rd6l8g42ri9fp49";
          }
          {
            name = "viml";
            publisher = "dunstontc";
            version = "0.1.7";
            sha256 = "0r2dpd07lj8icpbl1nvgk08y6s73bzwv6njpj7m4fcapwjjvhb7l";
          }
          {
            name = "flow-for-vscode";
            publisher = "flowtype";
            version = "1.3.0";
            sha256 = "177vvhmkzxsk5crpsl77f4j4v2g2gb6jkn0vcf8ag5bbwqzd9bmm";
          }
          {
            name = "shell-format";
            publisher = "foxundermoon";
            version = "6.1.1";
            sha256 = "00znldmhy7ns56jv4fm490hdkaxfabq953pbyn6r0z6kj42rg7wz";
          }
          {
            name = "vscode-styled-components";
            publisher = "jpoissonnier";
            version = "0.0.26";
            sha256 = "09lgc1fjdrgzw6n72w833kyfk7m0008lmd17r0vljcd572igfhhc";
          }
          {
            name = "Go";
            publisher = "ms-vscode";
            version = "0.11.4";
            sha256 = "0h0z4kgm0d2milbmna2j0saic3yq5p07l18dflyqwvm9zvjx9x5f";
          }
          {
            name = "jinjahtml";
            publisher = "samuelcolvin";
            version = "0.10.5";
            sha256 = "1mv2zkp09dgqdvvr42mwajm0cninqqw2g2adi5b5ki63niv5xx2y";
          }
          {
            name = "rust";
            publisher = "rust-lang";
            version = "0.6.1";
            sha256 = "0f66z6b374nvnrn7802dg0xz9f8wq6sjw3sb9ca533gn5jd7n297";
          }
          {
            name = "EditorConfig";
            publisher = "EditorConfig";
            version = "0.13.0";
            sha256 = "1dy7rf9w1mvk65fmxbvhbi5pf6cw2lwi07yhafq9x20c36g6dwyz";
          }
          {
            name = "vscode-typescript-tslint-plugin";
            publisher = "ms-vscode";
            version = "1.2.2";
            sha256 = "1n2yv37ljaadp84iipv7czzs32dbs4q2vmb98l3z0aan5w2g8x3z";
          }
          {
            name = "vscodeintellicode";
            publisher = "VisualStudioExptTeam";
            version = "1.1.9";
            sha256 = "00x203w2pacs68svccmbsq3hb7gyin2zblb1abyvqw0nxba5kzww";
          }
          {
            name = "vetur";
            publisher = "octref";
            version = "0.22.2";
            sha256 = "1746fdpbk2kb3hc3ygkszpkaxpm4sm6p8xpl5gw96jk2hdg8zx9b";
          }
          {
            name = "stylelint";
            publisher = "shinnn";
            version = "0.51.0";
            sha256 = "0qxa6jcfjl9vkx06shxjpa8k99ysvar3i0pzqdnc4aizjcayn3i4";
          }
          {
            name = "svelte-intellisense";
            publisher = "ardenivanov";
            version = "0.6.0";
            sha256 = "0x9d6yzs0cyj0cc6if4yvaalwilb1rddg4zzn5f70frnws1snzdv";
          }
          {
            name = "svelte-vscode";
            publisher = "JamesBirtles";
            version = "0.9.2";
            sha256 = "05h2nrnzzdyxkrpkmdnb5i0mb9xdxcqa3hr74frl82q6xk7k6djy";
          }
          {
            name = "material-theme";
            publisher = "zhuangtongfa";
            version = "2.27.1";
            sha256 = "01kxcl5j8r2j6y244yvybxyva8m48lv8xdhqf1n5y186p43mr5ny";
          }
        ];

      userSettings = {
        "debug.inlineValues" = true;
        "editor.fontFamily" = "'FuraCode Nerd Font',monospace";
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
        "workbench.colorTheme" = "One Dark Pro";
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
