{ pkgs, ... }:
let
  myPython = pkgs.python37;
in
{
  devshell.name = "odoo-doodba-11";

  commands = with pkgs; [
    { package = autoflake; }
    { package = black; }
    { package = gnumake; }
    { package = podman-compose; }
    { package = pre-commit; }
    { package = yandex-cloud; }
  ];

  devshell.packages = with pkgs; [
    curl
    html-tidy
    lessc
    myPython
    nodejs
    pgcopydb
    podman
    postgresql
    rsync
    shellcheck
    shfmt
    uv
    yamllint
  ];

  devshell.startup.venv.text = ''
    export UV_PYTHON_PREFERENCE=only-system
    export UV_PROJECT_ENVIRONMENT="$PRJ_DATA_DIR/venv"
    if [ ! -d "$UV_PROJECT_ENVIRONMENT" ]; then
      ${pkgs.uv}/bin/uv venv -p "${myPython}/bin/python3" "$UV_PROJECT_ENVIRONMENT"
      ${pkgs.uv}/bin/uv pip install -r requirements-dev.txt -r _distro/custom/dependencies/pip.txt
    fi
    source $UV_PROJECT_ENVIRONMENT/bin/activate
  '';

  env = [
    {
      name = "LD_LIBRARY_PATH";
      prefix = "$NIX_LD_LIBRARY_PATH";
    }
    {
      name = "PYTHONPATH";
      eval = pkgs.lib.concatStringsSep ":" [
        "$PRJ_ROOT/_distro/custom/src/odoo"
        "$PRJ_ROOT"
      ];
    }
  ];
}
