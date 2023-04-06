{ config, lib, pkgs, ... }:
let
  inherit (lib) mkForce mkIf;
  isWorkstation = config.meta.suites.workstation;
  isSyncEnabled = config.networking.hostName == "alien";
  docs_local = "${config.users.users.sk.home}/docs/main";
  nextcloudCommon = {
    url = "https://nx29561.your-storageshare.de";
    "username.fetch" = [ "command" "cat" config.sops.secrets.nextcloud-sk-vdirsyncer-username.path ];
    "password.fetch" = [ "command" "cat" config.sops.secrets.nextcloud-sk-vdirsyncer-password.path ];
  };
in
{
  services.vdirsyncer = {
    enable = isWorkstation;
    jobs = {
      nc = {
        enable = isSyncEnabled;
        user = "sk";
        group = "sk";
        timerConfig = { OnBootSec = "3m"; OnUnitActiveSec = "10m"; };
        config = {
          general = { };
          storages = {
            vcards_local = {
              type = "filesystem";
              path = "${docs_local}/vcards";
              fileext = ".vcf";
            };
            calendars_local = {
              type = "filesystem";
              path = "${docs_local}/journals/calendars";
              fileext = ".ics";
            };
            nc_carddav = nextcloudCommon // { type = "carddav"; };
            nc_caldav = nextcloudCommon // { type = "caldav"; };
          };
          pairs = {
            contacts = {
              a = "vcards_local";
              b = "nc_carddav";
              collections = [ [ "contacts" null "contacts" ] ];
              conflict_resolution = "a wins";
            };
            calendars = {
              a = "calendars_local";
              b = "nc_caldav";
              collections = [ [ "personal" "personal" "personal" ] ];
              conflict_resolution = "a wins";
            };
          };
        };
      };
    };
  };

  systemd.services."vdirsyncer@nc".serviceConfig = mkIf isSyncEnabled {
    ProtectHome = mkForce "tmpfs";
    BindPaths = [ "${docs_local}/journals/calendars" "${docs_local}/vcards" ];
  };

  home-manager.users.sk = { suites, ... }: {
    home.packages = with pkgs; [ khard khal ];

    xdg.configFile = {
      "khard/khard.conf".text = ''
        [addressbooks]
        [[contacts]]
        path = ${docs_local}/vcards

        [contact table]
        display = formatted_name
        show_uids = no
        show_kinds = yes
        sort = formatted_name
        localize_dates = no

        [vcard]
        preferred_version = 4.0
      '';
      "khal/config".text = ''
        [default]
        default_calendar = personal

        [locale]
        dateformat = %Y-%m-%d
        datetimeformat = %Y-%m-%d %H:%M
        firstweekday = 1
        default_timezone = ${config.time.timeZone}

        [calendars]
          [[personal]]
            path = ${docs_local}/journals/calendars/personal
            color = dark green
            priority = 10
      '';
    };
  };
}
