{ config, pkgs, username, lib, ...}:
let
  selfHM = config.home-manager.users."${username}";
in with builtins;
{
  home.file = {
    #
    # Functions
    #
    "${selfHM.xdg.configHome}/fish/functions/to-upper.fish".text = ''
      # Change case from lower case to upper case
      # @param     $@  String to upper
      # @return    string
      function to-upper
        echo $argv |tr '[:lower:]' '[:upper:]';
      end
    '';

    "${selfHM.xdg.configHome}/fish/functions/to-lower.fish".text = ''
      # Change case from upper case to lower case
      # @param     $@  String to lower
      # @return    string
      function to-lower
        echo $argv |tr '[:upper:]' '[:lower:]' ;
      end
    '';

    "${selfHM.xdg.configHome}/fish/functions/capitalize.fish".text = ''
      # Capitalize a string
      # @param    $@  string to capitalize
      # @return   String
      function capitalize
        set input "$argv"
        echo "$input" | sed 's/[^ _-]*/\u&/g'
      end
    '';

    #
    # Configuration modules
    #
    # Enable foreign env loader
    "${selfHM.xdg.configHome}/fish/conf.d/activate_fenv.fish".text = ''
      function activate_fenv --description 'Activate fenv'
        set fish_function_path ${pkgs.fish-foreign-env}/share/fish-foreign-env/functions $fish_function_path
      end
    '';

    # Load .profile
    "${selfHM.xdg.configHome}/fish/conf.d/load_profile.fish".text = ''
      function load_profile --description 'Load .profile'
        type -q fenv; and test -e ~/.profile; and begin
          fenv source ~/.profile
        end
      end
    '';

    # Fix term
    "${selfHM.xdg.configHome}/fish/conf.d/fix_term.fish".text = ''
      function fix_term --description "Fix $TERM and colors"
        test $TERM = "xterm-termite" -o $TERM = "termite"; and begin
          set -x TERM "xterm-256color"
        end

        # Enable truecolor/24-bit support for select terminals
        # Ignore Screen and emacs' ansi-term as they swallow the sequences, rendering the text white.
        if not set -q STY
            and not string match -q -- 'eterm*' $TERM
            and begin
                test -n "$VTE_VERSION" -a "$VTE_VERSION" -ge 3600
                or test "$COLORTERM" = truecolor -o "$COLORTERM" = 24bit
            end
            # Only set it if it isn't to allow override by setting to 0
            set -q fish_term24bit; or set -g fish_term24bit 1
        end
      end
    '';

    # Colorize man pages
    "${selfHM.xdg.configHome}/fish/conf.d/colorize_man_pages.fish".text = ''
      function colorize_man_pages --description 'Colorize man pages'
        set -gx LESS_TERMCAP_mb \e'[01;31m'       # begin blinking
        set -gx LESS_TERMCAP_md \e'[01;38;5;74m'  # begin bold
        set -gx LESS_TERMCAP_me \e'[0m'           # end mode
        set -gx LESS_TERMCAP_se \e'[0m'           # end standout-mode
        set -gx LESS_TERMCAP_so \e'[38;5;016m'\e'[48;5;220m' # begin standout-mode - info box
        set -gx LESS_TERMCAP_ue \e'[0m'           # end underline
        set -gx LESS_TERMCAP_us \e'[04;38;5;146m' # begin underline
      end
    '';

    # Enable Pure theme
    "${selfHM.xdg.configHome}/fish/conf.d/activate_pure_theme.fish".text = ''
      function activate_pure_theme --description 'Activate Pure theme'
        source ${pkgs.fish-theme-pure}/conf.d/pure.fish
        set fish_function_path ${pkgs.fish-theme-pure} $fish_function_path
        set pure_separate_prompt_on_error true
      end
    '';
  };

  programs.fish = {
    enable = true;
    shellAbbrs = {
      o = "xdg-open";
      svim = "sudo -E vim";
    };
    shellAliases = {
      fzf = "fzf-tmux -m";
      gmpv = "flatpak run --filesystem=xdg-download io.github.GnomeMpv --enqueue";
      grep = "grep  --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}";
      myip = "curl ifconfig.co";
      rsync-copy = "rsync -avz --progress -h";
      rsync-move = "rsync -avz --progress -h --remove-source-files";
      rsync-synchronize = "rsync -avzu --delete --progress -h";
      rsync-update = "rsync -avzu --progress -h";
    };
  };
}
