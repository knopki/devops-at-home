{
  config,
  lib,
  pkgs,
  osConfig,
  self,
  ...
}:
let
  inherit (lib) mkDefault mkIf optionals;
in
{
  home = {
    # by default, state version is machine's state version
    stateVersion = mkDefault (optionals (osConfig != null) osConfig.system.stateVersion);

    packages = with pkgs; [
      curl
      wget
      xsel
      wl-clipboard
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

  nix = mkIf (osConfig == null) {
    package = mkDefault pkgs.nix;
    settings = {
      inherit (self.nixConfig) experimental-features extra-substituters extra-trusted-public-keys;
    };
  };

  programs = {
    bat.enable = lib.mkDefault true;

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
  };

  # sometimes rewriten by evil forces and prevent activation
  # xdg.configFile."fontconfig/conf.d/10-hm-fonts.conf".force = true;
}
