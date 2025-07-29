{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  inherit (builtins) toString listToAttrs map;
  inherit (lib) concatStringsSep mkDefault;
in
{
  imports = with self.modules.homeManager; [
    legacy-theme
  ];

  home = {
    sessionVariables = {
      PATH = concatStringsSep ":" [
        "${config.home.homeDirectory}/.local/bin"
        "${config.xdg.dataHome}/npm/bin"
        "\${PATH}"
      ];
    };

    file = {
      ".config/autostart/org.keepassxc.KeePassXC.desktop".source =
        "${pkgs.keepassxc}/share/applications/org.keepassxc.KeePassXC.desktop";
    };
  };

  programs = {
    atuin = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      settings = {
        dialect = "uk";
        update_check = false;
        filter_mode = "host";
        filter_mode_shell_up_key_binding = "session";
        workspaces = true;
        style = "compact";
        inline_height = 40;
        exit_mode = "return-query";
        store_failed = false;
        enter_accept = false;
        keymap_mode = "vim-normal";
      };
      daemon.enable = true;
    };
  };

  qt.kde.settings = {
    kdeglobals.General = {
      BrowserApplication = "brave-browser.desktop";
      TerminalApplication = mkDefault "konsole";
      TerminalService = mkDefault "org.kde.konsole.desktop";
    };

    kactivitymanagerdrc = {
      Plugins = {
        "org.kde.ActivityManager.VirtualDesktopSwitchEnabled" = true;
      };
      activities = {
        "0da38162-91a8-4f68-9bff-8c318a46edc6" = "Default";
      };
    };

    kscreenlockerrc = {
      Daemon.Timeout = 15;
    };

    kwalletrc = {
      Wallet.Enabled = false;
      "org.freedesktop.secrets".apiEnabled = true;
    };

    kwinrc = {
      Plugins.lattewindowcolorsEnabled = true;
      Desktops = {
        Id_1 = "b8f777df-3a74-4bb1-9323-76c522965b2e";
        Id_2 = "5bc900c5-26d9-4b9e-98b9-5f0a8ee88e51";
        Id_3 = "c3a14783-7b31-495c-b3bd-47e73caa784f";
        Id_4 = "f15059f7-d2da-44ed-b6e6-1cd163259ea4";
        Id_5 = "c942e3a2-0087-40e8-a098-3ce79f275254";
        Id_6 = "9c47220e-3d2e-4ce9-a5b0-7b80fde1b1ae";
        Id_7 = "af20d7e1-b7ed-4cc3-a6d9-169c80826a13";
        Id_8 = "00b372f8-68df-496c-82cd-2a5e9191d50c";
        Id_9 = "93c94ddf-78d9-4786-9ee2-70c00704900e";
        Id_10 = "9cbdcf6b-2721-418c-82aa-1c11b346a382";
        Name_1 = 1;
        Name_2 = 2;
        Name_3 = 3;
        Name_4 = 4;
        Name_5 = 5;
        Name_6 = 6;
        Name_7 = 7;
        Name_8 = 8;
        Name_9 = 9;
        Name_10 = 10;
        Number = 10;
        Rows = 1;
      };
      NightColor = {
        Active = true;
      };
    };

    # hotkeys
    kglobalshortcutsrc = {
      "krunner.desktop" = {
        _k_friendly_name = "KRunner";
        _launch = "Alt+F2\tSearch,Alt+F2\tSearch,KRunner";
      };
      kwin = {
        "Switch to Desktop 1" = "Meta+1,none,Switch to Desktop 1";
        "Switch to Desktop 2" = "Meta+2,none,Switch to Desktop 2";
        "Switch to Desktop 3" = "Meta+3,none,Switch to Desktop 3";
        "Switch to Desktop 4" = "Meta+4,none,Switch to Desktop 4";
        "Switch to Desktop 5" = "Meta+5,none,Switch to Desktop 5";
        "Switch to Desktop 6" = "Meta+6,none,Switch to Desktop 6";
        "Switch to Desktop 7" = "Meta+7,none,Switch to Desktop 7";
        "Switch to Desktop 8" = "Meta+8,none,Switch to Desktop 8";
        "Switch to Desktop 9" = "Meta+9,none,Switch to Desktop 9";
        "Switch to Desktop 10" = "Meta+0,none,Switch to Desktop 10";

        "Window to Desktop 1" = "Meta+!,none,Window to Desktop 1";
        "Window to Desktop 2" = "Meta+@,none,Window to Desktop 2";
        "Window to Desktop 3" = "Meta+#,none,Window to Desktop 3";
        "Window to Desktop 4" = "Meta+$,none,Window to Desktop 4";
        "Window to Desktop 5" = "Meta+%,none,Window to Desktop 5";
        "Window to Desktop 6" = "Meta+^,none,Window to Desktop 6";
        "Window to Desktop 7" = "Meta+&,none,Window to Desktop 7";
        "Window to Desktop 8" = "Meta+*,none,Window to Desktop 8";
        "Window to Desktop 9" = "Meta+(,none,Window to Desktop 9";
        "Window to Desktop 10" = "Meta+),none,Window to Desktop 10";

        "Switch to Next Screen" = "Meta+.,none,Switch to Next Screen";
        "Switch to Previous Screen" = "Meta+,none,Switch to Previous Screen";

        "Window to Next Screen" = "Meta+>,Meta+Shift+Right,Window to Next Screen";
        "Window to Previous Screen" = "Meta+<,Meta+Shift+Left,Window to Previous Screen";

        "Window Close" = "Meta+Shift+Q\tAlt+F4,Alt+F4,Window Close";
      };

      "org.kde.dolphin.desktop" = {
        _k_friendly_name = "Dolphin";
        _launch = "Meta+E,Meta+E,";
      };

      "speedcrunch.desktop" = {
        _k_friendly_name = "SpeedCrunch";
        _launch = "Meta+C,none,SpeedCrunch";
      };

      plasmashell = listToAttrs (
        map
          (
            x:
            let
              name = "activate task manager entry ${toString (if x == 0 then 10 else x)}";
            in
            {
              inherit name;
              value = "none,none,${name}";
            }
          )
          [
            0
            1
            2
            3
            4
            5
            6
            7
            8
            9
          ]
      );
    };

    kwinrulesrc = {
      General.count = 1;
      # fix tiling for windows with big minimal size
      "1" = {
        Description = "Setting Minimum Geometry Size";
        minsize = "1,1";
        minsizerule = 2;
        types = 1;
      };
    };
  };

  services = {
    # use system gpg-agent
    gpg-agent.enable = false;
  };

  systemd.user = {
    sessionVariables = {
      TERMINAL = mkDefault "konsole -e";
    };
  };

  xdg = {
    enable = true;

    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${config.home.homeDirectory}/desktop";
      documents = "${config.home.homeDirectory}/docs";
      download = "${config.home.homeDirectory}/downloads";
      music = "${config.home.homeDirectory}/music";
      pictures = "${config.home.homeDirectory}/pics";
      publicShare = "${config.home.homeDirectory}/public";
      templates = "${config.home.homeDirectory}/templates";
      videos = "${config.home.homeDirectory}/videos";
    };

    mimeApps = {
      enable = true;
    };

    configFile = {
      "user-dirs.locale".text = "en_US";
      "user-dirs.dirs".force = true;

      "gtk-3.0/bookmarks".text = ''
        file://${config.home.homeDirectory}/dev Development
        file://${config.home.homeDirectory}/docs Documents
        file://${config.home.homeDirectory}/downloads Downloads
        file://${config.home.homeDirectory}/music Music
        file://${config.home.homeDirectory}/pics Pictures
        file://${config.home.homeDirectory}/videos Videos
        file://${config.home.homeDirectory}/library Library
        file://${config.home.homeDirectory}/trash Trash
      '';
    };
  };

  theme = {
    enable = true;
    preset = "dracula";
    fonts = {
      monospace = {
        family = "FiraCode Nerd Font Mono";
        size = 10;
        packages = with pkgs; [
          nerd-fonts.fira-code
          nerd-fonts.symbols-only
          fira-code-symbols
        ];
      };
    };
    components.plasma.enable = true;
  };
}
