{ config, lib, pkgs, ... }:
let
  inherit (lib) generators optional mkDefault;
  desktopItem = pkgs.makeDesktopItem {
    name = "hound";
    desktopName = "Hound";
    icon = "system-search";
    exec = "xdg-open http://${config.services.hound.listenAddress}/";
    categories = [ "System" ];
  };
in
{
  home.packages = optional config.services.hound.enable desktopItem;

  services.hound = {
    maxConcurrentIndexers = mkDefault 1;
    repositories = {
      nixpkgs = {
        url = "https://github.com/NixOS/nixpkgs.git";
        ms-between-poll = 86400000;
      };
      nix = {
        url = "https://github.com/NixOS/nix.git";
        ms-between-poll = 86400000;
      };
      home-manager = {
        url = "https://github.com/nix-community/home-manager.git";
        ms-between-poll = 86400000;
      };
      nur-combined = {
        url = "https://github.com/nix-community/nur-combined.git";
        ms-between-poll = 86400000;
      };
    };
  };
}
