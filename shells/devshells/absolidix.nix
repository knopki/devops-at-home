{
  config,
  inputs,
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
    $CONF_SET remote data_dir "$YASCHEDULER_DATA_DIR"
    $CONF_SET engine.dummy-test spawn "dummyengine *"
    $CONF_SET engine.dummy-test check_cmd "ps aux -ocomm= | grep -q dummyengine"
    $CONF_SET engine.dummy-test input_files "1.input 2.input 3.input"
    $CONF_SET engine.dummy-test output_files "1.input 2.input 3.input 1.input.out 2.input.out 3.input.out"
    $CONF_SET engine.inpgen spawn "inpgen -f aiida.in -o inp.xml"
    $CONF_SET engine.inpgen check_cmd "ps -eocomm= | grep -q inpgen"
    $CONF_SET engine.inpgen input_files "aiida.in"
    $CONF_SET engine.inpgen output_files "aiida.in inp.xml kpts.xml sym.xml default.econfig out scratch struct.xsf"
    $CONF_SET engine.fleur spawn "fleur"
    $CONF_SET engine.fleur check_cmd "ps -eocomm= | grep -q fleur"
    $CONF_SET engine.fleur input_files "inp.xml kpts.xml sym.xml relax.xml"
    $CONF_SET engine.fleur output_files "inp.xml kpts.xml sym.xml relax.xml out out.xml FleurInputSchema.xsd FleurOutputSchema.xsd juDFT_times.json"
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

  start-jupyter = pkgs.writeShellScriptBin "start-jupyter" ''
    ${enter-venv}
    exec uv run --with jupyter jupyter lab --no-browser --allow-root
  '';

  container-dockerfile = pkgs.writeText "Dockerfile" ''
    FROM docker.io/library/python:3.12-bookworm

    RUN apt-get update \
      && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        supervisor \
        openssh-server \
        postgresql \
        rabbitmq-server \
        libboost-dev swig wait-for-it \
      && rm -rf /var/lib/apt/lists/*

    ARG UV_URL=https://github.com/astral-sh/uv/releases/download/0.6.2/uv-x86_64-unknown-linux-gnu.tar.gz
    RUN curl -sSfL "$UV_URL" -o /tmp/uv.tar.gz \
      && tar xfv /tmp/uv.tar.gz --strip-component=1 -C /usr/local/bin \
      && rm /tmp/uv.tar.gz

    ENV LANG en_US.UTF-8
    RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

    WORKDIR /app
  '';

  container-path = concatStringsSep ":" [
    "/app/absolidix-backend/.venv/bin"
    "${packages.dummy-engine}/bin"
    "${packages.fleur}/bin"
    "/usr/local/sbin"
    "/usr/local/bin"
    "/usr/sbin"
    "/usr/bin"
    "/sbin"
    "/bin"
  ];

  absolidix-container-env-file = pkgs.writeText "env" ''
    PATH=${container-path}
    PGDATA=/data/postgres
    PGHOST=localhost
    PGPORT=5432
    PGUSER=postgres
    PGPASSWORD=
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
    command = /usr/sbin/rabbitmq-server
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

    ${pkgs.podman}/bin/podman unshare mkdir -p $PRJ_DATA_DIR/postgres
    ${pkgs.podman}/bin/podman unshare chown -R 103:105 $PRJ_DATA_DIR/postgres
    ${pkgs.podman}/bin/podman unshare mkdir -p $PRJ_DATA_DIR/rabbitmq
    ${pkgs.podman}/bin/podman unshare chown -R 104:106 $PRJ_DATA_DIR/rabbitmq
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
      -p 5432:5432 \
      -p 5555:5555 \
      -p 8888:8888 \
      --env-file ${absolidix-container-env-file} \
      --entrypoint /usr/bin/supervisord \
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
    pyright
    ruff
    ruff-lsp
    start-absolidix-container
    uv
    verdi
    yastatus
    yanodes
    psql
    swig
    packages.dummy-engine
    packages.fleur
  ];

  devshell.startup.setup-env.text = ''
    # Dynamic libraries
    export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH:$LD_LIBRARY_PATH

    # UV
    export UV_PYTHON_PREFERENCE=only-system
    export UV_PROJECT_ENVIRONMENT="$PRJ_DATA_DIR/venv"
    export UV_CACHE_DIR="$UV_PROJECT_ENVIRONMENT/cache"
    ${pkgs.uv}/bin/uv venv -p "${pkgs.python3}" "$UV_PROJECT_ENVIRONMENT" \
      --no-project --allow-existing
    source $UV_PROJECT_ENVIRONMENT/bin/activate
    ${pkgs.uv}/bin/uv pip install -e yascheduler
    ${pkgs.uv}/bin/uv pip install -e absolidix-backend
    ${pkgs.uv}/bin/uv pip install -e absolidix-client
  '';
}
