{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (lib) mkDefault optionals;
in
{
  home = {
    # by default, state version is machine's state version
    stateVersion = mkDefault (optionals (osConfig != null) osConfig.system.stateVersion);

    packages = with pkgs; [
      curl
      fishPlugins.foreign-env
      wget
    ];

    file = {
      ".curlrc".text = ''
        # Create the necessary local directory hierarchy as needed.
        create-dirs

        # Support gzip responses.
        compressed

        # Limit the time (in seconds) the connection to the server is allowed to take.
        connect-timeout = 30

        # Follow HTTP redirects.
        location

        # Display transfer progress as a progress bar.
        progress-bar
      '';

      ".wgetrc".text = ''
        # Use the server-provided last modification date, if available
        timestamping = on

        # Do not go up in the directory structure when downloading recursively
        no_parent = on

        # Wait 60 seconds before timing out. This applies to all timeouts: DNS, connect and read. (The default read timeout is 15 minutes!)
        timeout = 30

        # Retry a few times when a download fails, but don’t overdo it. (The default is 20!)
        tries = 10

        # Retry even when the connection was refused
        retry_connrefused = on

        # Use the last component of a redirection URL for the local file name
        trust_server_names = on

        # Follow FTP links from HTML documents by default
        follow_ftp = on

        # Add a `.html` extension to `text/html` or `application/xhtml+xml` files that lack one, or a `.css` extension to `text/css` files that lack one
        adjust_extension = on

        # Ignore `robots.txt` and `<meta name=robots content=nofollow>`
        robots = off

        # Print the HTTP and FTP server responses
        server_response = on
      '';
    };
  };

  nix = {
    package = mkDefault pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  programs = {
    bash.enable = lib.mkDefault true;

    bat.enable = lib.mkDefault true;

    direnv = {
      enable = lib.mkDefault true;
      nix-direnv.enable = true;
    };

    fish = {
      enable = mkDefault true;

      functions = {
        fish_hybrid_key_bindings = {
          description = "Vi-style bindings that inherit emacs-style bindings in all modes";
          body = ''
            for mode in default insert visual
                fish_default_key_bindings -M $mode
            end
            fish_vi_key_bindings --no-erase
            bind --user \e\[3\;5~ kill-word  # Ctrl-Delete
          '';
        };
      };

      interactiveShellInit = ''
        # keybindings
        set -g fish_key_bindings fish_hybrid_key_bindings

        # disable greeting
        set -u fish_greeting ""
      '';

      shellAbbrs = {
        gco = "git checkout";
        gst = "git status";
        o = "xdg-open";
      };

      shellAliases = {
        fzf = "fzf-tmux -m";
        grep = "grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}";
        myip = "curl ifconfig.co";
        rsync-copy = "rsync -avz --progress -h";
        rsync-move = "rsync -avz --progress -h --remove-source-files";
        rsync-synchronize = "rsync -avzu --delete --progress -h";
        rsync-update = "rsync -avzu --progress -h";
      };
    };

    fzf = {
      enable = lib.mkDefault true;
      defaultCommand = "${pkgs.fd}/bin/fd --type f";
      fileWidgetOptions = [ " --preview 'head {}'" ];
      changeDirWidgetCommand = "${pkgs.fd}/bin/fd --type d";
      changeDirWidgetOptions = [ "--preview 'tree -C {} | head -200'" ];
    };

    git = {
      enable = mkDefault true;

      aliases = {
        a = "add -p";
        co = "checkout";
        cob = "checkout -b";
        f = "fetch -p";
        c = "commit";
        p = "push";
        fpush = "push --force-with-lease";
        ba = "branch -a";
        bd = "branch -d";
        bD = "branch -D";
        d = "diff";
        dc = "diff --cached";
        ds = "diff --staged";
        r = "restore";
        rs = "restore --staged";
        st = "status -sb";

        # # reset
        undo = "reset --soft HEAD^";
        soft = "reset --soft";
        hard = "reset --hard";
        s1ft = "soft HEAD~1";
        h1rd = "hard HEAD~1";

        # logging
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        plog = "log --graph --pretty='format:%C(red)%d%C(reset) %C(yellow)%h%C(reset) %ar %C(green)%aN%C(reset) %s'";
        tlog = "log --stat --since='1 Day Ago' --graph --pretty=oneline --abbrev-commit --date=relative";
        rank = "shortlog -sn --no-merges";

        # delete merged branches
        bdm = "!git branch --merged | grep -v '*' | xargs -n 1 git branch -d";
      };

      extraConfig = {
        core = {
          whitespace = "space-before-tab,-indent-with-non-tab,trailing-space";
          quotepath = "off";
        };
        branch = {
          sort = "-committerdate";
        };
        log = {
          decorate = "short";
          abbrevCommit = "true";
        };
        pull.rebase = true;
        push = {
          default = "current";
          followTags = "true";
        };
        apply.whitespace = "fix";
        color.ui = "auto";
        "color \"branch\"" = {
          current = "yellow reverse";
          local = "yellow";
          remote = "green";
        };
        "color \"diff\"" = {
          meta = "yellow bold";
          frag = "magenta bold";
          old = "red";
          new = "green";
        };
        "color \"status\"" = {
          added = "yellow";
          changed = "green";
          untracked = "cyan";
        };
        diff = {
          renames = "copies";
        };
        "diff \"bin\"" = {
          textconv = "hexdump -v -C";
        };
        "diff \"odf\"" = {
          binary = "true";
          textconv = "odt2txt";
        };
        help = {
          autocorrect = "1";
        };
        merge = {
          log = "true";
          ff = "only";
          conflictstyle = "diff3";
        };
        rebase = {
          autosquash = "true";
        };
        include = {
          path = "local";
        };
        status = {
          showUntrackedFiles = "all";
        };
        transfer = {
          fsckobjects = "true";
        };
        init = {
          defaultBranch = "master";
        };
        # gpg.format = "ssh";
      };

      ignores = [
        "._*"
        ".direnv"
        ".DS_Store"
        ".vscode"
        "*.pyc"
        "Desktop.ini"
        "Thumbs.db"
      ];

      lfs = {
        enable = true;
        skipSmudge = true;
      };
    };

    htop = with config.lib.htop; {
      enable = lib.mkDefault true;
      settings =
        {
          hide_threads = true;
          hide_userland_threads = true;
          shadow_other_users = true;
          show_program_path = false;
          show_thread_names = true;
          sort_key = fields.PERCENT_MEM;
          highlight_base_name = true;
        }
        // (leftMeters [
          (bar "AllCPUs")
          (bar "Memory")
          (bar "Swap")
        ])
        // (rightMeters [
          (text "Tasks")
          (text "LoadAverage")
          (text "Uptime")
        ]);
    };

    jq.enable = lib.mkDefault true;

    lesspipe.enable = lib.mkDefault true;

    readline = {
      enable = lib.mkDefault true;
      bindings = {
        # These allow you to use ctrl+left/right arrow keys to jump the cursor over words
        "\e[5C" = "forward-word";
        "\e[5D" = "backward-word";
      };
      variables = {
        # do not make noise
        bell-style = "none";
      };
    };

    ssh = {
      enable = lib.mkDefault true;
      compression = false;
      controlMaster = "auto";
      controlPersist = "2h";
      extraConfig = ''
        AddKeysToAgent yes
      '';
      matchBlocks = {
        "localhost" = {
          compression = false;
          extraOptions = {
            ControlMaster = "no";
          };
        };
        "* !localhost" = {
          extraOptions = {
            ControlMaster = "auto";
            ControlPersist = "2h";
          };
        };
        "*" = {
          serverAliveCountMax = 10;
          extraOptions = {
            TCPKeepAlive = "yes";
            PubkeyAcceptedKeyTypes = "+ssh-rsa";
            HostkeyAlgorithms = "+ssh-rsa";
          };
        };
        "*.onion" = {
          proxyCommand = "socat - SOCKS4A:localhost:%h:%p,socksport=9050";
        };
      };
      forwardAgent = true;
      serverAliveInterval = 10;
    };

    tmux = {
      enable = lib.mkDefault true;
      # windows start from 1
      baseIndex = 1;
      clock24 = true;
      extraConfig = ''
        # enable activity alerts
        setw -g monitor-activity on
        set -g visual-activity off
        set-option -g bell-action none

        # change terminal info
        set -g set-titles on
        set -g set-titles-string "#T"

        # jump to left/right window
        bind-key -n M-PPage previous-window
        bind-key -n M-NPage next-window

        # mouse
        set -g mouse on

        # mouse scrolling
        bind -n WheelUpPane   if-shell -F -t = "#{alternate_on}" "send-keys -M" "select-pane -t =; copy-mode -e; send-keys -M"
        bind -n WheelDownPane if-shell -F -t = "#{alternate_on}" "send-keys -M" "select-pane -t =; send-keys -M"

        # fix keys
        set-window-option -g xterm-keys on

        # show hostname
        set -g status-right ' #(hostname -s) '

        # fix alacritty 24 color
        set -ga terminal-overrides ",alacritty:Tc"
      '';
      newSession = true;
      plugins = with pkgs.tmuxPlugins; [
        pain-control
        sensible
        yank
      ];
    };
  };

  # sometimes rewriten by evil forces and prevent activation
  # xdg.configFile."fontconfig/conf.d/10-hm-fonts.conf".force = true;
}
