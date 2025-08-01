{
  inputs,
  pkgs,
  ...
}:
let
  myPython = pkgs.python3;
in
{
  imports = [ "${inputs.devshell}/extra/services/postgres.nix" ];

  devshell.name = "esdd";

  commands = [ ];

  devshell.packages = with pkgs; [
    myPython
    nodejs
    postgresql
    ruff
    uv
  ];

  devshell.startup.venv.text = ''
    export UV_PYTHON_PREFERENCE=only-system
    export UV_PROJECT_ENVIRONMENT="$PRJ_DATA_DIR/venv"
    if [ ! -d "$UV_PROJECT_ENVIRONMENT" ]; then
      ${pkgs.uv}/bin/uv venv -p "${myPython}" "$UV_PROJECT_ENVIRONMENT"
    fi
    source $UV_PROJECT_ENVIRONMENT/bin/activate
  '';

  env = [
    {
      name = "PATH";
      prefix = "$PRJ_ROOT/esdd-gui/node_modules/.bin";
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
