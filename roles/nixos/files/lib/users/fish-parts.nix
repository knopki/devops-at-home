{ pkgs }:
{
  functions = {
    to-upper = ''
      # Change case from lower case to upper case
      # @param     $@  String to upper
      # @return    string
      function to-upper
        echo $argv |tr '[:lower:]' '[:upper:]';
      end
    '';

    to-lower = ''
      # Change case from upper case to lower case
      # @param     $@  String to lower
      # @return    string
      function to-lower
        echo $argv |tr '[:upper:]' '[:lower:]' ;
      end
    '';

    capitalize = ''
      # Capitalize a string
      # @param    $@  string to capitalize
      # @return   String
      function capitalize
          set input "$argv"
          echo "$input" | sed 's/[^ _-]*/\u&/g'
      end
    '';
  };

  interactiveShellInitCommon = ''
    # fix strange $TERM
    if test $TERM = "xterm-termite" -o $TERM = "termite"
      set -x TERM "xterm-256color"
    end

    # Enable truecolor/24-bit support for select terminals
    # Ignore Screen and emacs' ansi-term as they swallow the sequences, rendering the text white.
    if not set -q STY
        and not string match -q -- 'eterm*' $TERM
        and begin
            test -n "$VTE_VERSION" -a "$VTE_VERSION" -ge 3600 # Should be all gtk3-vte-based terms after version 3.6.0.0
            or test "$COLORTERM" = truecolor -o "$COLORTERM" = 24bit # slang expects this
        end
        # Only set it if it isn't to allow override by setting to 0
        set -q fish_term24bit
        or set -g fish_term24bit 1
    end

    # Enable Pure theme
    if test $THEME_PURE = true
      source ${pkgs.fish-theme-pure}/conf.d/pure.fish
      set fish_function_path ${pkgs.fish-theme-pure} $fish_function_path
      set pure_separate_prompt_on_error true
    end

    # LESS colored man pages
    set -gx LESS_TERMCAP_mb \e'[01;31m'       # begin blinking
    set -gx LESS_TERMCAP_md \e'[01;38;5;74m'  # begin bold
    set -gx LESS_TERMCAP_me \e'[0m'           # end mode
    set -gx LESS_TERMCAP_se \e'[0m'           # end standout-mode
    set -gx LESS_TERMCAP_so \e'[38;5;016m'\e'[48;5;220m' # begin standout-mode - info box
    set -gx LESS_TERMCAP_ue \e'[0m'           # end underline
    set -gx LESS_TERMCAP_us \e'[04;38;5;146m' # begin underline
  '';

  shellInitCommon = ''
    # Load fenv
    set fish_function_path ${pkgs.fish-foreign-env}/share/fish-foreign-env/functions $fish_function_path

    # Load .profile
    if type -q fenv -a (test -e ~/.profile)
      fenv source ~/.profile
    end
  '';
}
