{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.programs.vscode;

  vscodePname = cfg.package.pname;

  jsonFormat = pkgs.formats.json { };

  configDir = {
    "vscode" = "Code";
    "vscode-insiders" = "Code - Insiders";
    "vscodium" = "VSCodium";
  }.${vscodePname};

  extensionDir = {
    "vscode" = "vscode";
    "vscode-insiders" = "vscode-insiders";
    "vscodium" = "vscode-oss";
  }.${vscodePname};

  userDir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "Library/Application Support/${configDir}/User"
    else
      "${config.xdg.configHome}/${configDir}/User";

  configFilePath = "${userDir}/settings.json";
  keybindingsFilePath = "${userDir}/keybindings.json";

  # TODO: On Darwin where are the extensions?
  extensionPath = ".${extensionDir}/extensions";

  dropNullFields = filterAttrs (_: v: v != null);

  settingsJson = jsonFormat.generate "vscode-user-settings" cfg.userSettings;
  keybindingsJson = jsonFormat.generate "vscode-keybindings"
    (map dropNullFields cfg.keybindings);

  mkActivationScript = { policy, userCfg, jqArgs }:
    hm.dag.entryAfter [ "writeBoundary" ] ''
      if [[ -f "${userCfg}" ]]; then
        $DRY_RUN_CMD ${pkgs.demjson}/bin/jsonlint -Sf ${userCfg} | \
          (${pkgs.jq}/bin/jq ${jqArgs} "${policy}"; dd status=none of=/dev/null) | \
          ${pkgs.moreutils}/bin/sponge "${userCfg}"
      else
        $DRY_RUN_CMD cp "${policy}" "${userCfg}" && chmod +600 "${userCfg}"
      fi
    '';
in
{
  disabledModules = [ "programs/vscode.nix" ];

  options = {
    programs.vscode = {
      enable = mkEnableOption "Visual Studio Code";

      activationMode = mkOption {
        type = types.enum [ "symlink" "merge" ];
        default = "symlink";
        description = ''
          How to apply settings and keyboard shortcuts.

          By default, in <literal>symlink</literal> mode, the configuration is
          created in the nix store, and symbolic links are created in the
          user's home directory. The configuration is read-only.

          In <literal>merge</literal> mode, the configuration is merged with
          the configuration in the user's home directory on every activation.
          The configuration is writable.
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.vscode;
        example = literalExample "pkgs.vscodium";
        description = ''
          Version of Visual Studio Code to install.
        '';
      };

      userSettings = mkOption {
        type = jsonFormat.type;
        default = { };
        example = literalExample ''
          {
            "update.channel" = "none";
            "[nix]"."editor.tabSize" = 2;
          }
        '';
        description = ''
          Configuration written to Visual Studio Code's
          <filename>settings.json</filename>.
        '';
      };

      keybindings = mkOption {
        type = types.listOf (types.submodule {
          options = {
            key = mkOption {
              type = types.str;
              example = "ctrl+c";
              description = "The key or key-combination to bind.";
            };

            command = mkOption {
              type = types.str;
              example = "editor.action.clipboardCopyAction";
              description = "The VS Code command to execute.";
            };

            when = mkOption {
              type = types.nullOr (types.str);
              default = null;
              example = "textInputFocus";
              description = "Optional context filter.";
            };

            # https://code.visualstudio.com/docs/getstarted/keybindings#_command-arguments
            args = mkOption {
              type = jsonFormat.type;
              default = null;
              example = { direction = "up"; };
              description = "Optional arguments for a command.";
            };
          };
        });
        default = [ ];
        example = literalExample ''
          [
            {
              key = "ctrl+c";
              command = "editor.action.clipboardCopyAction";
              when = "textInputFocus";
            }
          ]
        '';
        description = ''
          Keybindings written to Visual Studio Code's
          <filename>keybindings.json</filename>.
        '';
      };

      extensions = mkOption {
        type = types.listOf types.package;
        default = [ ];
        example = literalExample "[ pkgs.vscode-extensions.bbenoist.Nix ]";
        description = ''
          The extensions Visual Studio Code should be started with.
          These will override but not delete manually installed ones.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # Adapted from https://discourse.nixos.org/t/vscode-extensions-setup/1801/2
    home.file =
      let
        subDir = "share/vscode/extensions";
        toPaths = path:
          # Links every dir in path to the extension path.
          mapAttrsToList
            (k: _: { "${extensionPath}/${k}".source = "${path}/${subDir}/${k}"; })
            (builtins.readDir (path + "/${subDir}"));
        toSymlink = concatMap toPaths cfg.extensions;
      in
      foldr (a: b: a // b)
        {
          "${configFilePath}" = mkIf (cfg.activationMode == "symlink" && cfg.userSettings != { }) {
            source = settingsJson;
          };
          "${keybindingsFilePath}" = mkIf (cfg.activationMode == "symlink" && cfg.keybindings != [ ]) {
            source = keybindingsJson;
          };
        }
        toSymlink;

    home.activation = mkIf (cfg.activationMode == "merge") (mkMerge [
      (optionalAttrs (cfg.userSettings != { }) {
        vscodeSettings = mkActivationScript {
          policy = settingsJson;
          userCfg = configFilePath;
          jqArgs = "-n 'reduce inputs as $i ({}; $i * .)'";
        };
      })
      (optionalAttrs (cfg.keybindings != [ ]) {
        vscodeKeybindings = mkActivationScript {
          policy = keybindingsJson;
          userCfg = keybindingsFilePath;
          jqArgs = "-s 'add | unique_by(.key + .when + .args)'";
        };
      })
    ]);

    xdg.configFile."${userDir}/.keep".text = "";
  };
}
