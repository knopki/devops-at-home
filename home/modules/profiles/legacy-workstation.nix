{
  config,
  lib,
  pkgs,
  self,
  osConfig,
  ...
}:
let
  inherit (lib) mkBefore mkDefault optionals;
in
{
  imports = with self.modules.homeManager; [ profiles-legacy-graphical ];

  home.language = {
    monetary = mkDefault "ru_RU.UTF-8";
    time = mkDefault "ru_RU.UTF-8";
  };

  programs = {
    firefox.profiles.default.settings = {
      "browser.search.countryCode" = mkDefault "RU";
      "browser.search.region" = mkDefault "RU";
      "intl.locale.requested" = mkDefault "ru,en-US";
    };

    fish.shellInit = mkBefore ''
      export LANG=en_US.UTF-8
    '';

    git.delta.enable = mkDefault true;

    kde.settings = {
      kdeglobals = {
        Locale = {
          Country = mkDefault "ru";
          TimeFormat = mkDefault "%H:%M:%S";
          WeekStartDay = mkDefault 1;
        };
      };

      ktimezonedrc.TimeZones.LocalZone = mkDefault (optionals (osConfig != null) osConfig.time.timeZone);

      kxkbrc = {
        Layout = {
          LayoutList = mkDefault (optionals (osConfig != null) osConfig.services.xserver.layout);
          Options = mkDefault "terminate:ctrl_alt_bksp,grp:win_space_toggle";
        };
      };

      plasma-localerc = {
        Formats = {
          LANG = mkDefault "ru_RU.UTF-8";
          LC_NUMERIC = mkDefault "en_US.UTF-8";
          useDetailed = mkDefault true;
        };
        Translations.LANGUAGE = mkDefault "ru:en_US";
      };
    };

    man.generateCaches = mkDefault true;

    password-store = {
      enable = mkDefault true;
      package = pkgs.pass.withExtensions (
        ext: with ext; [
          pass-checkup
          pass-genphrase
          pass-otp
          pass-update
        ]
      );
    };

    starship = {
      enable = mkDefault true;
      settings = {
        aws.disabled = mkDefault true;
        conda.disabled = mkDefault true;
        crystal.disabled = mkDefault true;
        directory = {
          truncation_length = mkDefault 2;
          fish_style_pwd_dir_length = mkDefault 2;
        };
        elixir.disabled = mkDefault true;
        elm.disabled = mkDefault true;
        gcloud.disabled = mkDefault true;
        nim.disabled = mkDefault true;
        kubernetes.disabled = mkDefault true;
        purescript.disabled = mkDefault true;
        zig.disabled = mkDefault true;
      };
    };
  };

  services.syncthing = {
    enable = true;
    tray.enable = true;
  };

  systemd.user = {
    # delay start
    services.${config.services.syncthing.tray.package.pname} = {
      Install.WantedBy = lib.mkForce [ ];
    };

    timers.${config.services.syncthing.tray.package.pname} = {
      Timer = {
        OnActiveSec = "10s";
        AccuracySec = "1s";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
