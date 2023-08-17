{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    python3Full
  ];

  home.file = {
    # HACK: support virtualenv and nix shells
    ".pylintrc".text = ''
      [MASTER]
      init-hook='import os,sys;[sys.path.append(p) for p in os.environ.get("PYTHONPATH","").split(":")];'
    '';
  };
}
