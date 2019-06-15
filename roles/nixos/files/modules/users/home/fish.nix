{ config, lib, pkgs, user, ... }:
with lib;
let
  fishCfgDir = "${config.xdg.configHome}/fish";
  initExmaple = ''
    99-at-the-end = ''''
      do_something_et_the_end();
    '''';
  '';
in {
  options.local.fish = {
    enable = mkEnableOption "enable fish shell for user";
    defaultFuncs = mkEnableOption "add standard functions to fish";
    ffe = mkEnableOption "enable foreign environment loader for fish";
    loadProfile = mkEnableOption "load .profile by fish";
    fixTerm = mkEnableOption "fix $TERM in fish";
    colorizeMan = mkEnableOption "fix $TERM in fish";
    pureTheme = mkEnableOption "enable Pure fish theme";

    shellInit = mkOption {
      default = {};
      description = ''
        Attribute set of lines ordered by attribute name, called during
        fish shell initialisation.
      '';
      type = with types; attrsOf lines;
      example = initExmaple;
    };

    loginShellInit = mkOption {
      default = {};
      description = ''
        Attribute set of lines ordered by attribute name, called during
        fish login shell initialisation.
      '';
      type = with types; attrsOf lines;
      example = initExmaple;
    };

    interactiveShellInit = mkOption {
      default = {};
      description = ''
        Attribute set of lines ordered by attribute name, called during
        interactive fish shell initialisation.
      '';
      type = with types; attrsOf lines;
      example = initExmaple;
    };

    promptInit = mkOption {
      default = {};
      description = ''
        Attribute set of lines ordered by attribute name,
        used to initialise fish prompt.
      '';
      type = with types; attrsOf lines;
      example = initExmaple;
    };
  };

  config = mkIf config.local.fish.enable (mkMerge [
    {
      home.packages = with pkgs; [ fish ];

      programs.fish = {
        enable = true;
        shellInit = concatStringsSep
          "\n"
          (attrValues config.local.fish.shellInit);
        loginShellInit = concatStringsSep
          "\n"
          (attrValues config.local.fish.loginShellInit);
        interactiveShellInit = concatStringsSep
          "\n"
          (attrValues config.local.fish.interactiveShellInit);
        promptInit = concatStringsSep
          "\n"
          (attrValues config.local.fish.promptInit);
        shellAbbrs = {
          o = "xdg-open";
          svim = "sudo -E vim";
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

      local.fzf.enable = true;
    }

    #
    # Functions
    #
    (mkIf config.local.fish.defaultFuncs {
      home.file = {
        "${fishCfgDir}/functions/to-upper.fish".text = ''
          # Change case from lower case to upper case
          # @param     $@  String to upper
          # @return    string
          function to-upper
            echo $argv |tr '[:lower:]' '[:upper:]';
          end
        '';

        "${fishCfgDir}/functions/to-lower.fish".text = ''
          # Change case from upper case to lower case
          # @param     $@  String to lower
          # @return    string
          function to-lower
            echo $argv |tr '[:upper:]' '[:lower:]' ;
          end
        '';

        "${fishCfgDir}/functions/capitalize.fish".text = ''
          # Capitalize a string
          # @param    $@  string to capitalize
          # @return   String
          function capitalize
            set input "$argv"
            echo "$input" | sed 's/[^ _-]*/\u&/g'
          end
        '';
      };
    })

    # foreign environment loader
    (mkIf config.local.fish.ffe {
      home.file."${fishCfgDir}/conf.d/activate_fenv.fish".text = ''
        function activate_fenv --description 'Activate fenv'
          set fish_function_path ${pkgs.fish-foreign-env}/share/fish-foreign-env/functions $fish_function_path
        end
      '';
      home.packages = with pkgs; [ fish-foreign-env ];
      local.fish.shellInit."00-ffe" = "activate_fenv # activate fenv command";
    })

    # load .profile
    (mkIf config.local.fish.loadProfile {
      home.file."${fishCfgDir}/conf.d/load_profile.fish".text = ''
        function load_profile --description 'Load .profile'
          type -q fenv; and test -e ~/.profile; and begin
            fenv source ~/.profile
          end
        end
      '';
      local.fish.ffe = true;
      local.fish.shellInit."10-load-profile" = "load_profile # load profile with fenv";
    })

    # fix $TERM
    (mkIf config.local.fish.fixTerm {
      home.file."${fishCfgDir}/conf.d/fix_term.fish".text = ''
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
      local.fish.interactiveShellInit."00-fix-term" = "fix_term # setup terminal";
    })

    # colorize man pages
    (mkIf config.local.fish.colorizeMan {
      home.file."${fishCfgDir}/conf.d/colorize_man_pages.fish".text = ''
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
      local.fish.interactiveShellInit."50-colorize-man" = "colorize_man_pages # Colored man pages";
    })

    # colorize man pages
    (mkIf config.local.fish.pureTheme {
      home.file."${fishCfgDir}/conf.d/activate_pure_theme.fish".text = ''
        function activate_pure_theme --description 'Activate Pure theme'
          set fish_function_path ${pkgs.fish-theme-pure}/share/fish/vendor_functions.d $fish_function_path
          set fish_function_path ${pkgs.fish-theme-pure} $fish_function_path
          source ${pkgs.fish-theme-pure}/conf.d/pure.fish
          set pure_separate_prompt_on_error true
        end
      '';
      local.fish.interactiveShellInit."50-pure-theme" = "activate_pure_theme # Pure theme";
    })
  ]);
}
