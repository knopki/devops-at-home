{
  pkgs,
  packages,
  ...
}:
let
  inherit (pkgs.lib) concatStringsSep;

  aiidaDbName = "aiida";
  absolidixDbName = "absolidix";

  enter-venv = ''
    uv venv --project $UV_PROJECT --allow-existing
    source $UV_PROJECT_ENVIRONMENT/bin/activate
  '';

  start-sshd = pkgs.writeShellScriptBin "start-sshd" ''
    mkdir -p /run/sshd
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
    sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords yes/g' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    exec /usr/sbin/sshd -D
  '';

  setup-postgres = pkgs.writeShellScriptBin "setup-postgres" ''
    set -euo pipefail
    [[ ! -f "$PGDATA/postgresql.conf" ]] || exit 0

    /usr/lib/postgresql/15/bin/initdb

    cat >> "$PGDATA/postgresql.conf" <<EOF
      unix_socket_directories = '$PGDATA'
    EOF

    /usr/lib/postgresql/15/bin/postgres --single -E postgres << EOF
      CREATE EXTENSION IF NOT EXISTS pgcrypto;
      CREATE DATABASE ${aiidaDbName} ENCODING 'UTF8' LC_COLLATE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8';
      CREATE DATABASE ${absolidixDbName} ENCODING 'UTF8' LC_COLLATE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8';
    EOF
  '';

  start-postgres = pkgs.writeShellScriptBin "start-postgres" ''
    set -euo pipefail
    ${setup-postgres}/bin/setup-postgres
    exec /usr/lib/postgresql/15/bin/postgres
  '';

  setup-aiida-py = pkgs.writeScript "setup-aiida.py" ''
    #!/usr/bin/env python3

    import os
    import aiida
    from aiida import orm
    from aiida.manage.configuration import load_profile, create_profile, create_default_user, get_config
    from aiida.brokers.rabbitmq.defaults import BROKER_DEFAULTS
    from aiida.manage.manager import Manager

    config = get_config(create=True)

    user_config = {
        "email": "user@example.org",
        "first_name": "Giuseppe",
        "last_name": "Verdi",
        "institution": "LaScala",
    }
    storage_backend = "core.psql_dos"
    storage_config = {
        "database_hostname": os.getenv("PGHOST"),
        "database_port": os.getenv("PGPORT"),
        "database_username": os.getenv("PGUSER"),
        "database_password": os.getenv("PGPASSWORD"),
        "database_name": os.getenv("AIIDA_DBNAME"),
        "repository_uri": f"file://{os.getenv("AIIDA_REPO")}",
    }
    broker_backend = "core.rabbitmq"
    broker_config = { **BROKER_DEFAULTS }

    try:
        profile = create_profile(
            config=config,
            name="default",
            **user_config,
            storage_backend=storage_backend,
            storage_config=storage_config,
            broker_backend=broker_backend,
            broker_config={},
        )
    except ValueError:
        profile = load_profile()

    profile.set_storage(storage_backend, storage_config)
    profile.set_process_controller(broker_backend, broker_config)
    profile.set_option("warnings.rabbitmq_version", False)
    profile.set_option("warnings.showdeprecations", False)

    config.update_profile(profile)
    config.set_default_profile("default")
    config.store()

    users = orm.users.UserCollection(orm.users.User)
    _, user = users.get_or_create(user_config["email"])

    computers = orm.computers.ComputerCollection(orm.computers.Computer)
    _, computer = computers.get_or_create("localhost")
    computer.hostname = "localhost"
    computer.set_default_mpiprocs_per_machine(1)
    computer.set_shebang("#!/usr/bin/env bash")
    computer.set_workdir(os.getenv("AIIDA_REPO"))
    computer.transport_type = "core.local"
    computer.scheduler_type = "core.direct"
    computer.configure(safe_interval=1.0, use_login_shell=False)
    computer.store()

    _, computer = computers.get_or_create("yascheduler")
    computer.hostname = "localhost"
    computer.set_shebang("#!/usr/bin/env bash")
    computer.set_workdir(os.getenv("AIIDA_REPO"))
    computer.transport_type = "core.ssh"
    computer.scheduler_type = "yascheduler"
    computer.configure(safe_interval=1.0, username=os.getenv("USER"), port=22, key_filename=f"{os.getenv("YASCHEDULER_DATA_DIR")}/keys/localhost", key_policy="AutoAddPolicy")
    computer.store()

    for label, plugin, exe in [
        ("add", "core.arithmetic.add", "/bin/sh"),
        ("dummy", "aiida_dummy", "/bin/sh"),
        ("inpgen", "fleur.inpgen", "inpgen"),
        ("fleur", "fleur.fleur", "fleur"),
    ]:
        code = None
        hide = []
        codes = orm.InstalledCode.Collection(orm.InstalledCode)
        for c in codes.find({"label": label, "dbcomputer_id": computer.id}):
            if (
                (code is not None)
                or (c.is_hidden)
                or (c.filepath_executable is not exe)
                or (c.use_double_quotes is False)
                or (c.default_calc_job_plugin is not plugin)
            ):
                hide.append(c)
            else:
                code = c

        if not code:
            code = orm.InstalledCode(
                computer,
                label=label,
                filepath_executable=exe,
                use_double_quotes=True,
                default_calc_job_plugin=plugin,
            )
            code.store()

        for code in hide:
            code.label = f"{label}_archived"
            code.is_hidden = True
            code.store()
  '';

  setup-aiida = pkgs.writeShellScriptBin "setup-aiida" ''
    set -euo pipefail
    ${enter-venv}
    uv pip install "aiida-core[tui]>=2.6,<2.7"
    uv pip install "aiida-fleur>=2.0,<3.0"
    ${setup-aiida-py}
  '';

  start-aiida = pkgs.writeShellScriptBin "start-aiida" ''
    set -euo pipefail
    ${enter-venv}
    until pg_isready; do echo "Waiting for postgres..."; sleep 1; done
    ${setup-aiida}/bin/setup-aiida
    exec verdi daemon start --foreground
  '';

  setup-yascheduler = pkgs.writeShellScriptBin "setup-yascheduler" ''
    set -euo pipefail

    pushd /app
      if [ ! -d yascheduler ]; then git clone git@github.com:tilde-lab/yascheduler.git; fi
    popd
    until pg_isready; do echo "Waiting for postgres..."; sleep 1; done

    pushd /app/yascheduler
    ${enter-venv}
    uv pip install -e .
    cat yascheduler/data/schema.sql | sed -e "s/CREATE TABLE/CREATE TABLE IF NOT EXISTS/" | psql
    mkdir -p "$YASCHEDULER_DATA_DIR"
    if [ ! -f "$YASCHEDULER_CONF_PATH" ]; then
      cp yascheduler/data/yascheduler.conf "$YASCHEDULER_CONF_PATH"
    fi
    ${pkgs.crudini}/bin/crudini --del "$YASCHEDULER_CONF_PATH" remote user
    CONF_SET="${pkgs.crudini}/bin/crudini --set $YASCHEDULER_CONF_PATH"
    $CONF_SET db host "$PGHOST"
    $CONF_SET db port "$PGPORT"
    $CONF_SET db database "$PGDATABASE"
    $CONF_SET db user "$PGUSER"
    $CONF_SET db password "$PGPASSWORD"
    $CONF_SET local data_dir "$YASCHEDULER_DATA_DIR"
    $CONF_SET local webhook_url "http://localhost:7050/calculations/update?key=$AB_WEBHOOKS__KEY"
    $CONF_SET remote data_dir "$YASCHEDULER_DATA_DIR"
    $CONF_SET engine.dummy platforms linux
    $CONF_SET engine.dummy deploy_local_files dummyengine
    $CONF_SET engine.dummy spawn "{engine_path}/dummyengine *"
    $CONF_SET engine.dummy check_pname dummyengine
    $CONF_SET engine.dummy sleep_interval 1
    $CONF_SET engine.dummy input_files "1.input 2.input 3.input"
    $CONF_SET engine.dummy output_files "1.input 2.input 3.input 1.input.out 2.input.out 3.input.out"
    $CONF_SET engine.pcrystal platforms linux
    $CONF_SET engine.pcrystal platform_packages "openmpi-bin wget"
    $CONF_SET engine.pcrystal deploy_local_files Pcrystal
    $CONF_SET engine.pcrystal check_pname Pcrystal
    $CONF_SET engine.pcrystal sleep_interval 6
    $CONF_SET engine.pcrystal spawn "cp {task_path}/INPUT OUTPUT && mpirun -np {ncpus} --allow-run-as-root -wd {task_path} {engine_path}/Pcrystal >> OUTPUT 2>&1"
    $CONF_SET engine.pcrystal input_files "INPUT fort.34"
    $CONF_SET engine.pcrystal input_files "INPUT fort.34 OUTPUT fort.9 fort.87"
    $CONF_SET engine.inpgen spawn "inpgen -explicit -inc +all -f aiida.in > shell.out 2> out.error"
    $CONF_SET engine.inpgen check_cmd "ps -eocomm= | grep -q inpgen"
    $CONF_SET engine.inpgen input_files "aiida.in"
    $CONF_SET engine.inpgen output_files "aiida.in inp.xml default.econfig shell.out out out.error scratch struct.xsf"
    $CONF_SET engine.fleur spawn "fleur -minimalOutput -wtime 360 > shell.out 2> out.error"
    $CONF_SET engine.fleur check_cmd "ps -eocomm= | grep -q fleur"
    $CONF_SET engine.fleur input_files "inp.xml"
    $CONF_SET engine.fleur output_files "inp.xml kpts.xml sym.xml relax.xml shell.out out.error out out.xml FleurInputSchema.xsd FleurOutputSchema.xsd juDFT_times.json cdn1 usage.json"
    popd

    if [ ! -f "$YASCHEDULER_DATA_DIR/keys/localhost" ]; then
      mkdir -p "$YASCHEDULER_DATA_DIR/keys"
      ssh-keygen -t rsa -N "" -f "$YASCHEDULER_DATA_DIR/keys/localhost"
      mv "$YASCHEDULER_DATA_DIR/keys/localhost.pub" ~/.ssh/authorized_keys
    else
      ssh-keygen -y -f "$YASCHEDULER_DATA_DIR/keys/localhost" > ~/.ssh/authorized_keys
    fi

    echo "PATH=$PATH" > /etc/profile.d/path.sh

    yasetnode --skip-setup=true root@127.0.0.1~1
  '';

  start-yascheduler = pkgs.writeShellScriptBin "start-yascheduler" ''
    set -euo pipefail
    until pg_isready; do echo "Waiting for postgres..."; sleep 1; done
    ${setup-yascheduler}/bin/setup-yascheduler
    exec $UV_PROJECT_ENVIRONMENT/bin/yascheduler -l DEBUG
  '';

  setup-backend = pkgs.writeShellScriptBin "setup-absolidix-backend" ''
    set -euo pipefail
    until pg_isready; do echo "Waiting for postgres..."; sleep 1; done

    pushd /app/absolidix-backend
    ${enter-venv}
    uv pip install -e .[dev]
    cat schema/schema.sql | psql
    popd
  '';

  start-backend = pkgs.writeShellScriptBin "start-absolidix-backend" ''
    set -euo pipefail
    ${enter-venv}
    until pg_isready; do echo "Waiting for postgres..."; sleep 1; done
    ${setup-backend}/bin/setup-absolidix-backend
    pushd /app/absolidix-backend
    exec python3 index.py
    popd
  '';

  setup-bff = pkgs.writeShellScriptBin "setup-absolidix-bff" ''
    set -euo pipefail
    until pg_isready; do echo "Waiting for postgres..."; sleep 1; done

    pushd /app/absolidix-bff
    npm install

    if [ ! -f conf/env.ini ]; then
      cp conf/env.ini.sample conf/env.ini
    fi

    CONF_SET="${pkgs.crudini}/bin/crudini --set conf/env.ini"
    $CONF_SET db data "$PGDATABASE"
    $CONF_SET db host "$PGHOST"
    $CONF_SET db port "$PGPORT"
    $CONF_SET db user "$PGUSER"
    $CONF_SET db password "$PGPASSWORD"
    $CONF_SET api.dev key "$AB_API__KEY"
    $CONF_SET api.dev schema http
    $CONF_SET api.dev host localhost
    $CONF_SET api.dev port 7050

    npm run db-migrate
    popd
  '';

  start-bff = pkgs.writeShellScriptBin "start-absolidix-bff" ''
    set -euo pipefail
    until pg_isready; do echo "Waiting for postgres..."; sleep 1; done
    NODE_ENV=development
    PORT=3000
    ${setup-bff}/bin/setup-absolidix-bff
    pushd /app/absolidix-bff
    exec npm run dev
    popd
  '';

  start-gui = pkgs.writeShellScriptBin "start-absolidix-gui" ''
    set -euo pipefail
    pushd /app/absolidix-gui
    npm install
    sed -i "s/^export const IdPs.*$/export const IdPs = ['local'];/g" src/config.ts
    exec npm run dev
    popd
  '';

  start-jupyter = pkgs.writeShellScriptBin "start-jupyter" ''
    ${enter-venv}
    exec uv run --with jupyter jupyter lab --no-browser --allow-root
  '';

  container-entrypoint = pkgs.writeShellScriptBin "entrypoint" ''
    mkdir -p /data/postgres
    chown -R postgres:postgres /data/postgres
    exec /usr/bin/supervisord $@
  '';

  container-dockerfile = pkgs.writeText "Dockerfile" ''
    FROM docker.io/library/python:3.12-bookworm

    RUN apt-get update \
      && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        supervisor \
        openssh-server \
        postgresql \
        libboost-dev swig wait-for-it \
      && rm -rf /var/lib/apt/lists/*

    ENV LANG en_US.UTF-8
    RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

    WORKDIR /app
  '';

  myContainerEnv = pkgs.buildEnv {
    name = "absolidix-container";
    paths = with pkgs; [
      packages.fleur
      start-sshd
      setup-postgres
      start-postgres
      setup-aiida
      start-aiida
      setup-yascheduler
      start-yascheduler
      setup-backend
      start-backend
      setup-bff
      start-bff
      start-gui
      start-jupyter
      container-entrypoint
      uv
      rabbitmq-server
      nodejs
    ];
    pathsToLink = [
      "/share"
      "/bin"
    ];
  };

  container-path = concatStringsSep ":" [
    "/app/absolidix-backend/.venv/bin"
    "${myContainerEnv}/bin"
    "/usr/local/sbin"
    "/usr/local/bin"
    "/usr/sbin"
    "/usr/bin"
    "/sbin"
    "/bin"
  ];

  absolidix-container-env-file =
    let
      pghost = "localhost";
      pguser = "postgres";
      pgpassword = "";
      ab_api_key = "ab_api_key";
      bff_api_key = "bff_api_key";
    in
    pkgs.writeText "env" ''
      PATH=${container-path}
      PGDATA=/data/postgres
      PGHOST=${pghost}
      PGPORT=5432
      PGUSER=${pguser}
      PGPASSWORD=${pgpassword}
      PGDATABASE=${absolidixDbName}

      RABBITMQ_BASE=/data/rabbitmq
      RABBITMQ_HOME=/data/rabbitmq
      RABBITMQ_CONFIG_FILE=/data/rabbitmq/rabbitmq
      RABBITMQ_MNESIA_BASE=/data/rabbitmq/mnesia
      RABBITMQ_LOG_BASE=/data/rabbitmq/log

      AIIDA_PATH=/data/aiida
      AIIDA_DBNAME=${aiidaDbName}
      AIIDA_REPO=/data/aiida/repo/default

      YASCHEDULER_DATA_DIR=/data/yascheduler
      YASCHEDULER_CONF_PATH=/data/yascheduler/yascheduler.conf
      YASCHEDULER_LOG_PATH=/data/yascheduler/yascheduler.log
      YASCHEDULER_PID_PATH=/data/yascheduler/yascheduler.pid

      UV_PROJECT=/app/absolidix-backend
      UV_PROJECT_ENVIRONMENT=/app/absolidix-backend/.venv
      UV_CACHE_DIR=/app/absolidix-backend/.venv/cache
      PYTHONBREAKPOINT=web_pdb.set_trace

      AB_DB__HOST=${pghost}
      AB_DB__DATABASE=${absolidixDbName}
      AB_DB__USER=${pguser}
      AB_DB__PASSWORD=${pgpassword}
      AB_API__KEY=${ab_api_key}
      AB_API__HOST=0.0.0.0
      AB_WEBHOOKS__KEY=${bff_api_key}
      AB_WEBHOOKS__CREATE_URL=http://localhost:3000/v0/webhooks/calc_create
      AB_WEBHOOKS__UPDATE_URL=http://localhost:3000/v0/webhooks/calc_update
      AB_LOCAL__PCRYSTAL_BS_PATH=/tmp
      BFF_WEBHOOKS_KEY=${ab_api_key}
      BFF_WEBHOOKS_CREATE_URL=http://localhost:3000/v0/webhooks/calc_create
      BFF_WEBHOOKS_UPDATE_URL=http://localhost:3000/v0/webhooks/calc_update
    '';

  supervisord-config = pkgs.writeText "supervisord.conf" ''
    [supervisord]
    nodaemon = true
    user = root

    [program:sshd]
    command = ${start-sshd}/bin/start-sshd
    user = root
    stdout_logfile = /dev/stdout
    stdout_logfile_maxbytes = 0
    redirect_stderr = true
    autorestart = true
    priority = 10

    [program:postgres]
    command = ${start-postgres}/bin/start-postgres
    user = postgres
    stdout_logfile = /dev/stdout
    stdout_logfile_maxbytes = 0
    redirect_stderr = true
    autorestart = true
    priority = 1

    [program:rabbitmq]
    command = ${pkgs.rabbitmq-server}/bin/rabbitmq-server
    user = root
    stdout_logfile = /dev/stdout
    stdout_logfile_maxbytes = 0
    redirect_stderr = true
    autorestart = true
    priority = 1

    [program:yascheduler]
    command = ${start-yascheduler}/bin/start-yascheduler
    user = root
    stdout_logfile = /dev/stdout
    stdout_logfile_maxbytes = 0
    redirect_stderr = true
    autorestart = true
    priority = 10

    [program:aiida]
    command = ${start-aiida}/bin/start-aiida
    user = root
    stdout_logfile = /dev/stdout
    stdout_logfile_maxbytes = 0
    redirect_stderr = true
    autorestart = true
    priority = 20

    [program:backend]
    command = ${start-backend}/bin/start-absolidix-backend
    user = root
    stdout_logfile = /dev/stdout
    stdout_logfile_maxbytes = 0
    redirect_stderr = true
    autorestart = true
    priority = 30

    [program:bff]
    command = ${start-bff}/bin/start-absolidix-bff
    user = root
    stdout_logfile = /dev/stdout
    stdout_logfile_maxbytes = 0
    redirect_stderr = true
    autorestart = true
    priority = 40

    [program:gui]
    command = ${start-gui}/bin/start-absolidix-gui
    user = root
    stdout_logfile = /dev/stdout
    stdout_logfile_maxbytes = 0
    redirect_stderr = true
    autorestart = true
    priority = 50

    [program:start-jupyter]
    command = ${start-jupyter}/bin/start-jupyter
    user = root
    stdout_logfile = /dev/stdout
    stdout_logfile_maxbytes = 0
    redirect_stderr = true
    autorestart = true
    priority = 99
  '';

  start-absolidix-container = pkgs.writeShellScriptBin "start-absolidix-container" ''
    set -euo pipefail
    ${pkgs.podman}/bin/podman build -t absolidix-all-in-one -f ${container-dockerfile} .

    mkdir -p $PRJ_DATA_DIR/aiida
    mkdir -p $PRJ_DATA_DIR/yascheduler

    ${pkgs.podman}/bin/podman run \
      --name absolidix-all-in-one \
      --rm --replace \
      --cpus 1.0 \
      --hostuser $USER \
      --init \
      -v /nix/store:/nix/store:ro \
      -v ${supervisord-config}:/etc/supervisor/conf.d/default.conf:ro \
      -v $PRJ_DATA_DIR/postgres:/data/postgres \
      -v $PRJ_DATA_DIR/aiida:/data/aiida \
      -v $PRJ_DATA_DIR/rabbitmq:/data/rabbitmq \
      -v $PRJ_DATA_DIR/yascheduler:/data/yascheduler \
      -v $PRJ_ROOT:/app \
      -v ${absolidix-container-env-file}:/etc/environment \
      -p 3000:3000 \
      -p 5000:5000 \
      -p 5432:5432 \
      -p 5555:5555 \
      -p 7050:7050 \
      -p 8080:8080 \
      -p 8888:8888 \
      --env-file ${absolidix-container-env-file} \
      --entrypoint ${container-entrypoint}/bin/entrypoint \
      localhost/absolidix-all-in-one
  '';

  exec-container = pkgs.writeShellScriptBin "exec-container" ''
    exec ${pkgs.podman}/bin/podman exec -it absolidix-all-in-one $@
  '';

  enter-container = pkgs.writeShellScriptBin "enter-container" ''
    exec ${exec-container}/bin/exec-container /bin/bash
  '';

  verdi = pkgs.writeShellScriptBin "_verdi" ''
    exec ${exec-container}/bin/exec-container /app/absolidix-backend/.venv/bin/verdi $@
  '';

  yanodes = pkgs.writeShellScriptBin "_yanodes" ''
    exec ${exec-container}/bin/exec-container /app/absolidix-backend/.venv/bin/yanodes $@
  '';

  yastatus = pkgs.writeShellScriptBin "_yastatus" ''
    exec ${exec-container}/bin/exec-container /app/absolidix-backend/.venv/bin/yastatus $@
  '';

  psql = pkgs.writeShellScriptBin "_psql" ''
    exec ${exec-container}/bin/exec-container /usr/bin/psql $@
  '';
in
{
  devshell.name = "absolidix";

  commands = [ ];

  devshell.packages = with pkgs; [
    gcc
    enter-container
    exec-container
    ruff
    ruff-lsp
    start-absolidix-container
    uv
    verdi
    yastatus
    yanodes
    psql
    swig
    packages.fleur
  ];

  devshell.startup.setup-env.text = ''
    # UV
    export UV_PYTHON_PREFERENCE=only-system
    export UV_PROJECT_ENVIRONMENT="$PRJ_DATA_DIR/venv"
    export UV_CACHE_DIR="$UV_PROJECT_ENVIRONMENT/cache"
    ${pkgs.uv}/bin/uv venv -p "${pkgs.python3}" "$UV_PROJECT_ENVIRONMENT" \
      --no-project --allow-existing
    source $UV_PROJECT_ENVIRONMENT/bin/activate
    ${pkgs.uv}/bin/uv pip install -e yascheduler
    ${pkgs.uv}/bin/uv pip install -e "absolidix-backend[dev]"
    ${pkgs.uv}/bin/uv pip install -e "absolidix-client[dev]"
  '';
}
