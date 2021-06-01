{ config, nixosConfig, lib, ... }:
let
  inherit (lib) elem mkIf;
  isVeryDev = elem nixosConfig.networking.hostName [ "alien" ];
in
{
  services.hound = {
    enable = true;
    repositories = {
      devops-at-home = mkIf isVeryDev {
        url = "https://github.com/knopki/devops-at-home.git";
        ms-between-poll = 86400000;
      };

      amperka-2018-theme = mkIf isVeryDev {
        url = "file://${config.home.homeDirectory}/dev/amperka-hq/amperka-2018-theme";
        ms-between-poll = 3600000;
      };
      amperka-com = mkIf isVeryDev {
        url = "file://${config.home.homeDirectory}/dev/amperka-hq/amperka-com";
        ms-between-poll = 3600000;
      };
      amperka-infra = mkIf isVeryDev {
        url = "file://${config.home.homeDirectory}/dev/amperka-hq/amperka-infra";
        ms-between-poll = 3600000;
      };
      iob = mkIf isVeryDev {
        url = "file://${config.home.homeDirectory}/dev/amperka-hq/insales-odoo-bridge";
        ms-between-poll = 3600000;
      };
      ins-mc = mkIf isVeryDev {
        url = "file://${config.home.homeDirectory}/dev/amperka-hq/ins-mc";
        ms-between-poll = 3600000;
      };
      store-cms = mkIf isVeryDev {
        url = "file://${config.home.homeDirectory}/dev/amperka-hq/store-cms";
        ms-between-poll = 3600000;
      };
      odoo = mkIf isVeryDev {
        url = "https://github.com/odoo/odoo.git";
        ms-between-poll = 3600000;
        vcs-config.ref = "11.0";
      };
      aodoo = mkIf isVeryDev {
        url = "file://${config.home.homeDirectory}/dev/nkrkv/amperka-odoo";
        ms-between-poll = 3600000;
      };
      pyinsales = mkIf isVeryDev {
        url = "https://github.com/nkrkv/pyinsales";
        ms-between-poll = 86400000;
      };

      xod = mkIf isVeryDev {
        url = "https://github.com/xodio/xod.git";
        ms-between-poll = 86400000;
      };
      xod-docs = mkIf isVeryDev {
        url = "https://github.com/xodio/xod-docs.git";
        ms-between-poll = 86400000;
      };
      xod-svc = mkIf isVeryDev {
        url = "file://${config.home.homeDirectory}/dev/xodio/services.xod.io";
        ms-between-poll = 3600000;
      };
      awasm = mkIf isVeryDev {
        url = "file://${config.home.homeDirectory}/dev/xodio/arduino-wasm-package";
        ms-between-poll = 3600000;
      };
    };
  };
}
