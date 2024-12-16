{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [ "${inputs.devshell}/extra/services/postgres.nix" ];

  devshell.name = "esdd";

  commands = [ ];

  devshell.packages = with pkgs; [
    nodejs
    postgresql
    pyright
    ruff
    ruff-lsp
    steam-run
    uv
    (python3.withPackages (python-pkgs: with python-pkgs; [ pip ]))
  ];

  devshell.startup.fix-esdd-gui.text = ''
    DART_DIR="$PRJ_ROOT/esdd-gui/node_modules/sass-embedded-linux-x64/dart-sass/src"
    if [ ! -f "$DART_DIR/dart_wrapper" ]; then
      echo -e "#!/usr/bin/env sh\nsteam-run $DART_DIR/dart.orig \$@" > "$DART_DIR/dart_wrapper"
      chmod +x "$DART_DIR/dart_wrapper"
    fi
    if [ ! -L "$DART_DIR/dart" ]; then
      mv "$DART_DIR/dart" "$DART_DIR/dart.orig"
      ln -s "$DART_DIR/dart_wrapper" "$DART_DIR/dart"
    fi
    # rm -r "$DART_DIR/dart"
  '';

  env = [
    {
      name = "PATH";
      prefix = "$PRJ_ROOT/esdd-gui/node_modules/.bin";
    }
    {
      name = "LD_LIBRARY_PATH";
      value = "${pkgs.stdenv.cc.cc.lib}/lib/";
    }
  ];

  services.postgres = {
    initdbArgs = [ ];
    setupPostgresOnStartup = true;
  };

  serviceGroups = {
    esdd = {
      name = "esdd-services";
      services = {
        db = {
          command = "start-postgres";
        };
        smtp = {
          command = "${pkgs.mailpit}/bin/mailpit";
        };
        # esdd-online = {
        #   command = "uvicorn main:app --reload --app-dir \"$PRJ_ROOT/esdd-online\" --reload-dir \"$PRJ_ROOT/esdd-online\"";
        # };
      };
    };
  };
}
