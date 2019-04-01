{ config, lib, pkgs, user, ... }:
with lib;
{
  options.local.vscode.enable = mkEnableOption "VSCode with config and workspaces";

  config = mkIf config.local.vscode.enable {
    home.file = {
      "${config.home.homeDirectory}/dev/xodio/xod.code-workspace".text = builtins.toJSON {
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
      extensions = with pkgs.vscode-extensions; [
        bbenoist.Nix
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
          version = "9.5.1";
          sha256 = "10s2g98wv8i0w6fr0pr5xyi8zmh229zn30jn1gg3m5szpaqi1v92";
        }
        {
          name = "indent-rainbow";
          publisher = "oderwat";
          version = "7.2.4";
          sha256 = "02b71r4jfzppm8i65yghw37kmk67ymrm1sdlkv13lj24k297d3v6";
        }
        {
          name = "vscode-kubernetes-tools";
          publisher = "ms-kubernetes-tools";
          version = "0.1.16";
          sha256 = "0hdlxh36gllzm9k83lkad5c2bwlfwhnzv5q98hwgpx2bj6s9cara";
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
          version = "8.4.0";
          sha256 = "0s5r8gsdyvkh471906mf4msf95xxrmr3p4msq93p8ldj7wwka18r";
        }
        {
          name = "vscode-yaml";
          publisher = "redhat";
          version = "0.3.0";
          sha256 = "13f094s3qgm3lby7q026gjnamm5bpwj3aqsnwa8qv3y22a7a784j";
        }
        {
          name = "vscode-eslint";
          publisher = "dbaeumer";
          version = "1.8.0";
          sha256 = "0mk1ijbrkj0h3g5pm95arh3aka4jz47zzr8m81055h8q6xsj0rzm";
        }
        {
          name = "prettier-vscode";
          publisher = "esbenp";
          version = "1.8.1";
          sha256 = "0qcm2784n9qc4p77my1kwqrswpji7bp895ay17yzs5g84cj010ln";
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
          version = "1.0.1";
          sha256 = "0b3rldawl64divbf6rpk7crxxf6gpfiai84svafyif2726ibyjd2";
        }
        {
          name = "shell-format";
          publisher = "foxundermoon";
          version = "4.0.4";
          sha256 = "0s4jw2ybwp8aj8sgv7xk0qqy7w3cpbgqz8v9r6vpwalmm6g3319s";
        }
        {
          name = "vscode-styled-components";
          publisher = "jpoissonnier";
          version = "0.0.25";
          sha256 = "12qgx56g79snkf9r7sgmx3lv0gnzp7avf3a5910i0xq9shfr67n0";
        }
        {
          name = "python";
          publisher = "ms-python";
          version = "2019.1.0";
          sha256 = "1jp9i0qxdbrw3jk4in9za9cmfyrd6ii1ilgyg2van3mkq6xpp92w";
        }
        {
          name = "Go";
          publisher = "ms-vscode";
          version = "0.9.2";
          sha256 = "0yxnsby8zz1dvnx8nqrhi4xx316mpjf2hs2c5r6fkzh8zhjccwqz";
        }
        {
          name = "jinjahtml";
          publisher = "samuelcolvin";
          version = "0.9.0";
          sha256 = "14vshlq208qqznpz5qix6pl8h64z4fvyhvp1ijyss9fnl7jf2q54";
        }
        {
          name = "rust";
          publisher = "rust-lang";
          version = "0.6.0";
          sha256 = "1yympisq2p034vxvyn12nzhsmslls1yhfbf68yi3in0ly4xfrb19";
        }
        {
          name = "EditorConfig";
          publisher = "EditorConfig";
          version = "0.13.0";
          sha256 = "1dy7rf9w1mvk65fmxbvhbi5pf6cw2lwi07yhafq9x20c36g6dwyz";
        }
      ];

      userSettings = {
        "debug.inlineValues" = true;
        "docker.enableLinting" = true;
        "editor.fontFamily" = "'Hack Nerd Font','Droid Sans Mono', 'Courier New', monospace, 'Droid Sans Fallback'";
        "editor.fontLigatures" = true;
        "editor.minimap.enabled" = false;
        "editor.minimap.renderCharacters" = false;
        "editor.multiCursorModifier" = "alt";
        "editor.rulers" = [80 120];
        "editor.wordWrap" = "on";
        "explorer.confirmDelete" = false;
        "extensions.autoUpdate" = false;
        "files.autoSave" = "off";
        "flow.useNPMPackagedFlow" = true;
        "flow.useLSP" = true;
        "git.autofetch" = true;
        "githubPullRequests.hosts" = [
          {
            host = "https://github.com";
            username = "oauth";
            token = "system";
          }
        ];
        "gitlens.advanced.messages" = {
          suppressFileNotUnderSourceControlWarning = true;
          suppressShowKeyBindingsNotice = true;
          suppressUpdateNotice = true;
        };
        "gitlens.codeLens.authors.enabled" = false;
        "gitlens.codeLens.recentChange.enabled" = false;
        "gitlens.hovers.annotations.enabled" = false;
        "gitlens.keymap" = "chorded";
        "javascript.updateImportsOnFileMove.enabled" = "never";
        "javascript.validate.enable" = false;
        "prettier.trailingComma" = "es5";
        "tslint.packageManager" = "yarn";
        "typescript.check.tscVersion" = false;
        "typescript.disableAutomaticTypeAcquisition" = false;
        "update.channel" = "none";
        "vsicons.dontShowNewVersionMessage" = true;
        "window.titleBarStyle" = "custom";
        "window.zoomLevel" = 0;
        "workbench.colorTheme" = "Monokai";
        "workbench.startupEditor" = "newUntitledFile";
      };
    };
  };
}
