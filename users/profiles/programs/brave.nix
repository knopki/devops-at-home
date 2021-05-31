{ config, lib, ... }:
let
  inherit (lib) mkDefault mkMerge;
  extFiles = map
    (ext: {
      "BraveSoftware/Brave-Browser/External Extensions/${ext.id}.json".text = config.home.file."${config.xdg.configHome}/brave/External Extensions/${ext.id}.json".text;
    })
    config.programs.brave.extensions;
in
{
  programs.brave = {
    enable = mkDefault true;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
    ];
  };

  # temporary fix wrong path
  xdg.configFile = mkMerge extFiles;
}
