{
  config,
  inputs,
  pkgs,
  packages,
  ...
}:
let

  myPython = (
    pkgs.python3.withPackages (
      ps: with ps; [
        numpy
      ]
    )
  );

  myPostgres = pkgs.postgresql;

  aiidaDbName = "aiida";
  absolidixDbName = "absolidix";

  setup-postgres = pkgs.writeShellScriptBin "setup-postgres" ''
    set -euo pipefail
    [[ ! -d "$PGDATA" ]] || exit 0

    ${myPostgres}/bin/initdb

    cat >> "$PGDATA/postgresql.conf" <<EOF
      unix_socket_directories = '$PGDATA'
    EOF

    ${myPostgres}/bin/postgres --single -E postgres << EOF
      CREATE EXTENSION IF NOT EXISTS pgcrypto;
      CREATE DATABASE ${aiidaDbName} ENCODING 'UTF8' LC_COLLATE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8';
      CREATE DATABASE ${absolidixDbName} ENCODING 'UTF8' LC_COLLATE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8';
    EOF
  '';

  start-postgres = pkgs.writeShellScriptBin "start-postgres" ''
    set -euo pipefail
    ${setup-postgres}/bin/setup-postgres
    exec ${myPostgres}/bin/postgres
  '';

  setup-aiida = pkgs.writeShellScriptBin "setup-aiida" ''
    set -euo pipefail
    set -o xtrace

    ${pkgs.uv}/bin/uv pip install "aiida-core[tui]>=2.6,<2.7"
    ${pkgs.uv}/bin/uv pip install "aiida-fleur>=2.0,<3.0"

    until pg_isready; do echo "Waiting for postgres..."; sleep 1; done

    verdi profile show default >/dev/null || \
    verdi profile setup core.psql_dos --non-interactive \
      --profile-name default --set-as-default \
      --first-name Giuseppe --last-name Verdi \
      --email user@example.org --institution LaScala \
      --use-rabbitmq \
      --database-hostname "$PGHOST" \
      --database-port "$PGPORT" \
      --database-name "$AIIDA_DBNAME" \
      --database-username "$PGUSER" \
      --database-password "$PGPASSWORD" \
      --repository-uri "file://$AIIDA_REPO"
    verdi config set warnings.rabbitmq_version False

    verdi computer show localhost >/dev/null || \
    verdi computer setup --non-interactive --label=localhost --hostname=localhost \
          --mpiprocs-per-machine=1 --work-dir="$AIIDA_REPO" \
          --shebang "#!/usr/bin/env bash" \
          --transport core.local --scheduler=core.direct
    verdi computer configure core.local localhost --non-interactive \
          --safe-interval 1 --no-use-login-shell
    verdi computer test localhost --print-traceback

    # verdi computer setup --non-interactive --label=yascheduler --hostname=localhost \
    #  --transport=core.ssh --scheduler=yascheduler --work-dir=/data/aiida
    # verdi computer configure core.ssh --non-interactive --username=root --port=22 --key-filename=~/.ssh/id_rsa.pub --key-policy=AutoAddPolicy --safe-interval 1 yascheduler
    # verdi computer test yascheduler --print-traceback

    verdi code create core.code.installed --label add --computer=localhost \
      --default-calc-job-plugin core.arithmetic.add \
      --filepath-executable=$(which bash) -n


    # verdi code setup --non-interactive --label=Pcrystal --input-plugin=crystal_dft.parallel --on-computer --computer=yascheduler --remote-abs-path=/nonce
    # verdi code setup --non-interactive --label=Dummy --input-plugin=aiida_dummy --on-computer --computer=yascheduler --remote-abs-path=/nonce

  '';

  start-aiida = pkgs.writeShellScriptBin "start-aiida" ''
    set -euo pipefail
    ${setup-aiida}/bin/setup-aiida
    exec verdi daemon start --foreground
  '';
in
{
  devshell.name = "absolidix";

  commands = [ ];

  devshell.packages = with pkgs; [
    gcc
    graphviz-nox
    mpi
    myPostgres
    myPython
    nodejs
    pyright
    rabbitmq-server
    ruff
    ruff-lsp
    setup-aiida
    setup-postgres
    start-aiida
    start-postgres
    uv
    packages.fleur
  ];

  devshell.startup.setup-env.text = ''
    # Dynamic libraries
    export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH:$LD_LIBRARY_PATH

    # UV
    export UV_PYTHON_PREFERENCE=only-system
    export UV_PROJECT_ENVIRONMENT="$PRJ_DATA_DIR/venv"
    if [ ! -d "$UV_PROJECT_ENVIRONMENT" ]; then
      ${pkgs.uv}/bin/uv venv -p "${myPython}" "$UV_PROJECT_ENVIRONMENT"
    fi
    source $UV_PROJECT_ENVIRONMENT/bin/activate

    # Postgres
    export PGDATA="$PRJ_DATA_DIR/postgres"
    #export PGHOST="$PGDATA"
    export PGHOST="localhost"
    export PGPORT="5432"
    export PGUSER="$USER"
    export PGPASSWORD=""
    export PGDATABASE="${absolidixDbName}"
    echo "Postgresql Connection String: postgresql://''${USER}@/absolidix?host=''${PGHOST}"

    # RabbitMQ
    export RABBITMQ_BASE="$PRJ_DATA_DIR/rabbitmq"
    export RABBITMQ_HOME="$RABBITMQ_BASE"
    export RABBITMQ_CONFIG_FILE="$RABBITMQ_BASE/rabbitmq"
    export RABBITMQ_MNESIA_BASE="$RABBITMQ_BASE/mnesia"
    export RABBITMQ_LOG_BASE="$RABBITMQ_BASE/log"
    echo "RabbitMQ Connection String: amqp://guest:guest@localhost:5672"

    # Aiida
    export AIIDA_PATH="$PRJ_DATA_DIR/aiida"
    export AIIDA_DBNAME="${aiidaDbName}"
    export AIIDA_REPO="$AIIDA_PATH/repo/default"
  '';

  serviceGroups = {
    absolidix = {
      name = "absolidix-services";
      services = {
        db.command = "start-postgres";
        rabbitmq.command = "rabbitmq-server";
        aiida.command = "start-aiida";
        jupyter.command = "uv run --with jupyter jupyter lab --no-browser";
      };
    };
  };
}
