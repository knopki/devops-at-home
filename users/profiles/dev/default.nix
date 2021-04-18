{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    dive
    fishPlugins.fish-kubectl-completions
    google-cloud-sdk
    kubectl
    nodejs
    nodePackages.typescript
    nodePackages.prettier
    postman
    winbox-bin
  ];

  home.file = {
    ".npmrc".text = ''
      cache="${config.xdg.cacheHome}/npm"
      prefix="${config.xdg.dataHome}/npm"
    '';

    # HACK: support virtualenv and nix shells
    ".pylintrc".text = ''
      [MASTER]
      init-hook='import os,sys;[sys.path.append(p) for p in os.environ.get("PYTHONPATH","").split(":")];'
    '';
  };

  home.sessionVariables = {
    PATH = "${config.home.homeDirectory}/.local/bin:${config.xdg.dataHome}/npm/bin:\${PATH}";
  };
}
