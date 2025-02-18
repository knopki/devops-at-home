{
  config,
  inputs,
  pkgs,
  ...
}:
let
  myPython = pkgs.python3;
in
{
  devshell.name = "xod-db-sync";

  commands = [ ];

  devshell.packages = with pkgs; [
    myPython
    nodejs
    pyright
    ruff
    ruff-lsp
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
      name = "LD_LIBRARY_PATH";
      prefix = "$NIX_LD_LIBRARY_PATH";
    }
  ];
}
