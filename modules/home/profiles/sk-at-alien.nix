{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  inherit (builtins) toString listToAttrs map;
  inherit (lib)
    concatStringsSep
    mkDefault
    nameValuePair
    ;
  vimiumCommon = {
    exclusionRules = [
      {
        pattern = "https?://mail.google.com/*";
        passKeys = "";
      }
    ];
    keyMappings = ''
      # Navigating the current page:
      # ?         Show help
      # h         Scroll left
      # j, <c-e>  Scroll down
      # k, <c-y>  Scroll up
      # l         Scroll right
      # gg        Scroll to the top of the page
      # G         Scroll to the bottom of the page
      # d         Scroll a half page down
      # u         Scroll a half page up
      # f         Open a link in the current tab
      # F         Open a link in a new tab
      # r         Reload the page
      map R reload hard # Reload page, bypassing cache
      # gs        View page source
      # i         Enter insert mode
      # yy        Copy the current URL to the clipboard
      # yf        Copy a link URL to the clipboard
      # gf        Select the next frame on the page
      # gF        Select the page's main/top frame

      # Navigating to new pages:
      # o         Open URL, bookmark or history entry
      # O         Open URL, bookmark or history entry in a new tab
      # b         Open a bookmark
      # B         Open a bookmark in a new tab
      # p         Open the clipboard's URL in the current tab
      # P         Open the clipboard's URL in a new tab

      # Using find:
      # /         Enter find mode
      # n         Cycle forward to the next find match
      # N         Cycle backward to the previous find match

      # Navigating your history:
      # H         Go back in history
      # L         Go forward in history

      # Manipulating tabs:
      # J, gT     Go one tab left
      # K, gt     Go one tab right
      # g0        Go to the first tab
      # g$        Go to the last tab
      # <<        Move tab to the left
      # >>        Move tab to the right
      # t         Create new tab
      # ^         Go to previously-visited tab
      # yt        Duplicate current tab
      # x         Close current tab
      # X         Restore closed tab
      # T         Search through your open tabs
      # W         Move tab to new window
      # <a-p>     Pin or unpin current tab
      # <a-m>     Mute or unmute current tab
      map <a-M>   toggleMuteTab all # mute all tabs

      # Using marks:
      # m         Create a new mark (ma - set local mark "a", mA - set global mark "A")
      # `         Go to a mark (`` - jump back to the position before the prev jump)

      # Visual mode
      # v         Enter visual mode; use p/P to paste-and-go, use y to yank
      # V         Enter visual line mode
      # c         (in visual mode) enter caret mode
      # o         (in visual mode) swap anchor and the focus, move "other end"

      # Additional advanced browsing commands:
      # [[        Follow the link labeled previous or <
      # ]]        Follow the link labeled next or >
      # <a-f>     Open multiple links in a new tab
      # gi        Focus the first text input on the page
      # gu        Go up the URL hierarchy
      # gU        Go to root of current URL hierarchy
      # ge        Edit the current URL
      # gE        Edit the current URL and open in a new tab
      # zH        Scroll all the way to the left
      # zL        Scroll all the way to the right

      map <c-]> passNextKey # passthru next key
    '';
    searchEngines = ''
      d: https://duckduckgo.com/?q=%s DuckDuckGo

      g: https://google.com/search?q=%s Google
      gyear: https://google.com/search?hl=en&tbo=1&tbs=qdr:y&q=%s Google (last year only)
      gsite: javascript:location='https://www.google.com/search?num=100&q=site:'+escape(location.hostname)+'+%s' Google on this site
      gi: https://google.com/search?tbm=isch&q=%s Google Images
      gm: https://google.com/maps?q=%s Google maps
      gt: https://translate.google.com/?source=osdd#auto|auto|%s Google Translator
      yt: https://youtube.com/results?search_query=%s Youtube

      y: https://yandex.ru/search/?text=%s Yandex
      ym: https://yandex.ru/maps/?text=%s Yandex Maps

      b: https://www.bing.com/search?q=%s Bing

      w: https://www.wikipedia.org/w/index.php?title=Special:Search&search=%s Wikipedia
      wr: https://ru.wikipedia.org/w/index.php?title=Special:Search&search=%s Wikipedia (RU)

      gh: https://github.com/search?q=%s GitHub

      so: https://stackoverflow.com/search?q=%s StackOverflow

      wa: https://wolframalpha.com/input/?i=%s Wolfram|Alpha

      imdb: https://www.imdb.com/find?s=all&q=%s IMDB
    '';
    scrollStepSize = 60;
    linkHintNumbers = "0123456789";
    linkHintCharacters = "sadfjklewcmpgh";
    smoothScroll = true;
    grabBackFocus = false;
    hideHud = false;
    regexFindMode = true;
    ignoreKeyboardLayout = true;
    filterLinkHints = false;
    waitForEnterForFilteredHints = true;
    previousPatterns = "prev,previous,back,older,<,‹,←,«,≪,<<";
    nextPatterns = "next,more,newer,>,›,→,»,≫,>>";
    newTabUrl = "pages/blank.html";
    searchUrl = "https://duckduckgo.com/?q=";
    userDefinedLinkHintCss = ''
      /* linkhint boxes */
      div > .vimiumHintMarker {
        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#FFF785), color-stop(100%,#FFC542));
        border: 1px solid #E3BE23;
      }

      /* linkhint text */
      div > .vimiumHintMarker span {
        color: black;
        font-weight: bold;
        font-size: 12px;
      }

      div > .vimiumHintMarker > .matchingCharacter {
      }
    '';
  };
  vimiumFF = vimiumCommon // {
    settingsVersion = "1.67.1";
  };
  vimiumC = vimiumCommon // {
    settingsVersion = "1.67";
  };
in
{
  imports = with self.modules.homeManager; [
    profiles-legacy-base
    profiles-legacy-graphical
    profiles-legacy-workstation
    profiles-legacy-devbox
    profiles-mpv-ultimate-viewer
    profiles-doomed-emacs
    profiles-sk-at-alien-kopia
    profiles-sk-at-alien-mount-remote
    profiles-sk-at-alien-pim
    legacy-theme
  ];

  home = {
    stateVersion = "20.09";

    packages = with pkgs; [
      gpgme
      du-dust
      feh
      gh
    ];

    sessionVariables = {
      PATH = concatStringsSep ":" [
        "${config.home.homeDirectory}/.local/bin"
        "${config.xdg.configHome}/emacs/bin"
        "${config.xdg.dataHome}/npm/bin"
        "\${PATH}"
      ];
      EDITOR = "hx";
      VISUAL = "zeditor -w -n";
    };

    file = {
      ".gnupg/gpg-agent.conf".text = ''
        allow-emacs-pinentry
        allow-loopback-pinentry
        allow-preset-passphrase
        default-cache-ttl 2592000
        default-cache-ttl-ssh 2592000
        max-cache-ttl 2592000
        max-cache-ttl-ssh 2592000
      '';

      # keys to open with pam_gnupg
      ".pam-gnupg".text = ''
        C87C6FBFDA8F3C18CF9BE03F139F5BD50CFB1753 # ${config.programs.gpg.settings.default-key}
      '';

      # HACK: support virtualenv and nix shells
      ".pylintrc".text = ''
        [MASTER]
        init-hook='import os,sys;[sys.path.append(p) for p in os.environ.get("PYTHONPATH","").split(":")];'
      '';

      ".config/autostart/org.keepassxc.KeePassXC.desktop".source =
        "${pkgs.keepassxc}/share/applications/org.keepassxc.KeePassXC.desktop";

      ".terraformrc".text = ''
        provider_installation {
          network_mirror {
            url = "https://terraform-mirror.yandexcloud.net/"
            include = ["registry.terraform.io/*/*"]
          }
          direct {
            exclude = ["registry.terraform.io/*/*"]
          }
        }
      '';
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

    gpg = {
      enable = true;
      settings = {
        throw-keyids = true;
        default-key = "58A58B6FD38C6B66";
      };
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

  sops = {
    defaultSopsFile = ../../../secrets/sk-at-alien.yaml;
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
  };

  systemd.user = {
    sessionVariables = {
      TERMINAL = mkDefault "konsole -e";
    };

    tmpfiles.rules = [
      "e ${config.xdg.userDirs.download} - - - 30d"
      "e ${config.xdg.userDirs.pictures}/screenshots - - - 30d"
    ];
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
      defaultApplications =
        {
          "application/epub+zip" = "org.kde.okular.desktop";
          "application/pdf" = "org.kde.okular.desktop";
        }
        // (listToAttrs (
          map (x: nameValuePair x "org.kde.gwenview.desktop") [
            "image/bmp"
            "image/gif"
            "image/jpeg"
            "image/jpg"
            "image/pjpeg"
            "image/png"
            "image/svg+xml"
            "image/svg+xml-compressed"
            "image/tiff"
            "image/vnd.wap.wbmp"
            "image/x-bmp"
            "image/x-gray"
            "image/x-icb"
            "image/x-icns"
            "image/x-ico"
            "image/x-pcx"
            "image/x-png"
            "image/x-portable-anymap"
            "image/x-portable-bitmap"
            "image/x-portable-graymap"
            "image/x-portable-pixmap"
            "image/x-xbitmap"
            "image/x-xpixmap"
          ]
        ))
        // (listToAttrs (
          map (x: nameValuePair x "brave-browser.desktop") [
            "application/x-extension-htm"
            "application/x-extension-html"
            "application/x-extension-shtml"
            "application/x-extension-xht"
            "application/x-extension-xhtml"
            "application/xhtml+xml"
            "application/xml"
            "text/html"
            "x-scheme-handler/ftp"
            "x-scheme-handler/http"
            "x-scheme-handler/https"
            "x-scheme-handler/ipfs"
            "x-scheme-handler/ipns"
          ]
        ));
    };

    configFile = {
      "mimeapps.list".force = true;

      "user-dirs.locale".text = "en_US";
      "user-dirs.dirs".force = true;

      # powermanager - just copy
      "powermanagementprofilesrc" = {
        text = builtins.readFile ./powermanagementprofilesrc;
        force = true;
      };

      "vimium.ff.json".text = builtins.toJSON vimiumFF;
      "vimium.json".text = builtins.toJSON vimiumC;

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
