{ config, pkgs, username, lib, ...}:
let
  selfHM = config.home-manager.users."${username}";
  fishFunctions = (import ./fish-parts.nix { inherit pkgs; }).functions;
in with builtins;
{
  home.file = lib.mkMerge (
    map (x: {
      "${selfHM.xdg.configHome}/fish/functions/${x}.fish".text = fishFunctions.${x};
    }) [
      "capitalize"
      "to-lower"
      "to-upper"
    ]
  );

  programs.fish = {
    enable = true;
    shellAbbrs = {
      o = "xdg-open";
      svim = "sudo -E vim";
    };
    shellAliases = {
      fzf = "fzf-tmux -m";
      gmpv = "flatpak run --filesystem=xdg-download io.github.GnomeMpv --enqueue";
      grep = "grep  --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}";
      myip = "curl ifconfig.co";
      rsync-copy = "rsync -avz --progress -h";
      rsync-move = "rsync -avz --progress -h --remove-source-files";
      rsync-synchronize = "rsync -avzu --delete --progress -h";
      rsync-update = "rsync -avzu --progress -h";
    };
  };
}
