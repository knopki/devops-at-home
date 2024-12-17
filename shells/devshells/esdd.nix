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
    python3
    ruff
    ruff-lsp
    uv
  ];

  devshell.startup.venv.text = ''
    VIRTUAL_ENV="$PRJ_DATA_DIR/venv"
    export UV_PYTHON=$VIRTUAL_ENV/bin/python
    # Create a virtual environment if it doesn't exist
    if [ ! -d "$VIRTUAL_ENV" ]; then
      ${pkgs.uv}/bin/uv venv "$VIRTUAL_ENV"
    fi

    source $VIRTUAL_ENV/bin/activate
  '';

  env = [
    {
      name = "PATH";
      prefix = "$PRJ_ROOT/esdd-gui/node_modules/.bin";
    }
    {
      name = "UV_PYTHON_DOWNLOADS";
      value = "never";
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
      };
    };
  };
}
