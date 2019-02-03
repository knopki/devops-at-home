{ config, pkgs, username, lib, ...}:
let
  selfHM = config.home-manager.users."${username}";
  zshFunctions = (import ../zsh-functions.nix);
  zshPlugins = (import ../zsh-plugins.nix) { inherit pkgs; };
in with builtins;
{
  home.file = lib.mkMerge (
    map (x: {
      "${selfHM.programs.zsh.dotDir}/functions/${x}".text = zshFunctions.${x};
    }) [
      "cdf" "fcd" "fda" "fdr" "fe" "fgshow" "fgstash" "fh" "fkill" "fo" "gb"
      "gf" "gh" "gr" "gt" "is_in_git_repo" "save_pwd" "source_if_possible"
    ]
  );

  programs.zsh = {
    dotDir = ".config/zsh";
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;

    history = {
      expireDuplicatesFirst = true;
      extended = true;
      ignoreDups = true;
      path = ".local/share/zsh/history/history.$(date +%Y).$(whoami)@$(hostname -s)";
      save = 100000000;
      share = true;
      size = 100000000;
    };

    initExtra = ''
      # autoload functions
      fpath=( $ZDOTDIR/functions "''${fpath[@]}" )
      for f in `ls $ZDOTDIR/functions`; do
        autoload -Uz $f
      done

      # add functions to prompt
      precmd_functions=($precmd_functions save_pwd)

      #
      # Completion
      #
      unsetopt menu_complete # do not autoselect the first completion entry
      unsetopt flowcontrol
      setopt auto_menu        # show completion menu on succesive tab press
      setopt auto_name_dirs   # any parameter that is set to the absolute name of a directory immediately becomes a name for that directory
      setopt complete_in_word # Allow completion from within a word/phrase
      setopt always_to_end    # When completing from the middle of a word, move the cursor to the end of the word

      unsetopt correct_all # spelling correction for arguments
      setopt correct       # spelling correction for commands

      zmodload zsh/terminfo

      zmodload -i zsh/complist

      zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

      zstyle ':completion:*' list-colors '''

      zstyle ':completion:*:*:*:*:*' menu select
      zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
      zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"

      # disable named-directories autocompletion
      zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

      # Use caching so that commands like apt and dpkg complete are useable
      zstyle ':completion::complete:*' use-cache 1
      zstyle ':completion::complete:*' cache-path $ZCACHEDIR

      # Don't complete uninteresting users
      zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
        clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
        gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
        ldap lp mail mailman mailnull man messagebus mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
        operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
        usbmux uucp vcsa wwwrun xfs '_*'

      # ... unless we really want to.
      zstyle '*' single-ignored show

      expand-or-complete-with-dots() {
        # toggle line-wrapping off and back on again
        [[ -n "$terminfo[rmam]" && -n "$terminfo[smam]" ]] && echoti rmam
        print -Pn "%{%F{red}......%f%}"
        [[ -n "$terminfo[rmam]" && -n "$terminfo[smam]" ]] && echoti smam

        zle expand-or-complete
        zle redisplay
      }
      zle -N expand-or-complete-with-dots
      bindkey "^I" expand-or-complete-with-dots

      # continious rehash
      zstyle ':completion:*' rehash true

      # Google Cloud SDK
      if [ -f "${pkgs.google-cloud-sdk}/google-cloud-sdk/completion.zsh.inc" ]; then
        source "${pkgs.google-cloud-sdk}/google-cloud-sdk/completion.zsh.inc"
      fi

      #
      # History
      #
      mkdir -p $(dirname $HISTFILE)
      if [[ ! -e $HISTFILE ]]; then touch $HISTFILE; fi

      # Read all history files
      _TEMP=$(mktemp)
      cat $(dirname $HISTFILE)/history.* | awk -v date="WILL_NOT_APPEAR$(date +"%s")" '{if (sub(/\\$/,date)) printf "%s", $0; else print $0}' | LC_ALL=C sort -u | awk -v date="WILL_NOT_APPEAR$(date +"%s")" '{gsub('date',"\\\n"); print $0}' >$_TEMP
      fc -R $_TEMP
      rm $_TEMP

      setopt bang_hist # Treat the '!' character specially during expansion.
      setopt append_history
      setopt hist_ignore_all_dups      # Delete an old recorded event if a new event is a duplicate.
      setopt hist_find_no_dups  # Do not display a previously found event.
      setopt hist_ignore_space  # Do not record an event starting with a space.
      setopt hist_save_no_dups         # Do not write a duplicate event to the history file.
      setopt hist_verify        # Do not execute immediately upon history expansion.
      setopt inc_append_history # Write to the history file immediately, not when the shell exits.
      setopt hist_beep          # Beep when accessing non-existent history.

      #
      # Title
      #
      # set title for terminal multiplexors
      case "$TERM" in
      screen* | tmux*)
        print -Pn "\e]2;''${USER}@''${HOST}\a"
        ;;
      esac

      function title() {
        emulate -L zsh
        setopt prompt_subst

        [[ "$EMACS" == *term* ]] && return

        # if $2 is unset use $1 as default
        # if it is set and empty, leave it as is
        : ''${2=$1}

        case "$TERM" in
        cygwin | xterm* | putty* | rxvt* | ansi)
          print -Pn "\e]2;$2:q\a" # set window name
          print -Pn "\e]1;$1:q\a" # set tab name
          ;;
        screen* | tmux*)
          print -Pn "\ek$1:q\e\\" # set multiplexor window name
          ;;
        *)
          if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
            print -Pn "\e]2;$2:q\a" # set window name
            print -Pn "\e]1;$1:q\a" # set tab name
          else
            # Try to use terminfo to set the title
            # If the feature is available set title
            if [[ -n "$terminfo[fsl]" ]] && [[ -n "$terminfo[tsl]" ]]; then
              echoti tsl
              print -Pn "$1"
              echoti fsl
            fi
          fi
          ;;
        esac
      }

      ZSH_THEME_TERM_TAB_TITLE_IDLE="%15<..<%~%<<" #15 char left truncated PWD
      ZSH_THEME_TERM_TITLE_IDLE="%n@%m: %~"

      # Runs before showing the prompt
      function _title_precmd() {
        emulate -L zsh

        title $ZSH_THEME_TERM_TAB_TITLE_IDLE $ZSH_THEME_TERM_TITLE_IDLE
      }

      # Runs before executing the command
      function _title_preexec() {
        emulate -L zsh
        setopt extended_glob

        # cmd name only, or if this is sudo or ssh, the next cmd
        local CMD=''${1[(wr)^(*=*|sudo|ssh|mosh|rake|-*)]:gs/%/%%}
        local LINE="''${2:gs/%/%%}"

        title '$CMD' '%100>...>$LINE%<<'
      }

      precmd_functions+=(_title_precmd)
      preexec_functions+=(_title_preexec)


      #
      # Key Bindings
      #
      zmodload zsh/terminfo

      bindkey -e # Use emacs key bindings

      # [Home], [End], [Delete]
      bindkey "^[[1~" beginning-of-line
      bindkey "^[OH" beginning-of-line
      bindkey "^[[H" beginning-of-line
      bindkey "^[[4~" end-of-line
      bindkey "^[OF" end-of-line
      bindkey "^[[F" end-of-line
      bindkey "^[[3~" delete-char-or-list

      bindkey "^[[1;5C" forward-word                    # [Ctrl-RightArrow] - move forward one word
      bindkey "^[[1;5D" backward-word                   # [Ctrl-LeftArrow] - move backward one word
      bindkey "^[[3;5~" kill-word                       # [Ctrl+Delete] - kill word next to cursor
      bindkey "^H" backward-kill-word                   # [Ctrl+Backspace] - kill word prev to cursor

      bindkey "''${terminfo[kcbt]}" reverse-menu-complete # [Shift-Tab] - move through the completion menu backwards

      # zsh-users/zsh-history-substring-search
      bindkey "$terminfo[kcuu1]" history-substring-search-up
      bindkey "^[[A" history-substring-search-up
      bindkey "$terminfo[kcud1]" history-substring-search-down
      bindkey "^[[B" history-substring-search-down

      join-lines() {
        local item
        while read item; do
          echo -n "''${(q)item} "
        done
      }

      _bind-git-helper() {
        local char
        for c in $@; do
          eval "fzf-g$c-widget() { local result=\$(g$c | join-lines); zle reset-prompt; LBUFFER+=\$result }"
          eval "zle -N fzf-g$c-widget"
          eval "bindkey '^g^$c' fzf-g$c-widget"
        done
      }
      _bind-git-helper f b t r h
      unset -f _bind-git-helper


    '';

    localVariables = rec {
      # Directories
      ZDATADIR = "${selfHM.xdg.dataHome}/zsh";
      ZCACHEDIR = "${selfHM.xdg.cacheHome}/zsh";
      ZPLUGINSDIR = "${ZDATADIR}/plugins";

      # Treat these characters as part of a word.
      WORDCHARS = "";
      #WORDCHARS = '*?_-.[]~&;!#$%^(){}<>';

      YSU_HARDCORE = "1";
      ZSH_AUTOSUGGEST_USE_ASYNC = "true";
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=10";
    };

    loginExtra = ''
      # login extra
    '';


    # plugins = (import ../../lib/zsh-plugins.nix) { pkgs = pkgs; };
    plugins = with zshPlugins; [
      zsh-256color
      zsh-async
      pure
      zsh-completions
      calc
      you-should-use
      fast-syntax-highlighting
      zsh-history-substring-search
    ];

    profileExtra = ''
      # profile extra
    '';

    sessionVariables = {
      SESSIONVARTEST = "test";
    };

    shellAliases = {
      _fzf_complete_gopass = "_fzf_complete_pass";
      fzf = "fzf-tmux -m";
      gco = "git checkout";
      glog = "git log --graph --pretty=format:\"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset\"";
      gmpv = "flatpak run --filesystem=xdg-download io.github.GnomeMpv --enqueue";
      grep = "grep  --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}";
      gst = "git status";
      gundo = "git reset --soft HEAD^";
      history = "fc -il 1";
      ls = "ls --color=auto";
      man = "nocorrect man";
      mv = "nocorrect mv";
      o = "xdg-open";
      rsync-copy = "rsync -avz --progress -h";
      rsync-move = "rsync -avz --progress -h --remove-source-files";
      rsync-synchronize = "rsync -avzu --delete --progress -h";
      rsync-update = "rsync -avzu --progress -h";
      sudo = "nocorrect sudo";
      svim = "sudo -E vim";
    };
  };
}
