{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkForce mkIf;
  homePath = config.users.users.sk.home;
  jobCommon = {
    enable = true;
    user = "sk";
    group = "sk";
    timerConfig = {
      OnBootSec = "3m";
      OnUnitActiveSec = "10m";
    };
  };
  posteoCommon = {
    url = "https://posteo.de:8443";
    "username.fetch" = [
      "command"
      "cat"
      config.sops.secrets.knopki-posteo-vdirsyncer-username.path
    ];
    "password.fetch" = [
      "command"
      "cat"
      config.sops.secrets.knopki-posteo-vdirsyncer-password.path
    ];
  };
in
{
  sops.secrets = {
    knopki-posteo-vdirsyncer-username = {
      owner = config.users.users.sk.name;
    };
    knopki-posteo-vdirsyncer-password = {
      owner = config.users.users.sk.name;
    };
  };

  services.vdirsyncer = {
    enable = true;
    jobs = {
      posteo = jobCommon // {
        config = {
          general = { };
          storages = {
            posteo_carddav = posteoCommon // {
              type = "carddav";
            };
            contacts_local = {
              type = "filesystem";
              path = "~/.local/share/contacts";
              fileext = ".vcf";
            };

            posteo_caldav = posteoCommon // {
              type = "caldav";
            };
            calendars_local = {
              type = "filesystem";
              path = "~/.local/share/calendars";
              fileext = ".ics";
            };
          };
          pairs = {
            contacts = {
              a = "contacts_local";
              b = "posteo_carddav";
              collections = [
                [
                  "contacts"
                  "private"
                  "default"
                ]
              ];
              conflict_resolution = "a wins";
            };

            calendars = {
              a = "calendars_local";
              b = "posteo_caldav";
              collections = [
                [
                  "private"
                  "private"
                  "default"
                ]
                [
                  "ann"
                  "ann"
                  "fbtubx"
                ]
              ];
              conflict_resolution = "a wins";
            };
          };
        };
      };
    };
  };

  systemd.services."vdirsyncer@posteo".serviceConfig = {
    ProtectHome = mkForce "tmpfs";
    BindPaths = [
      "${homePath}/.local/share/calendars"
      "${homePath}/.local/share/contacts"
    ];
  };
}
