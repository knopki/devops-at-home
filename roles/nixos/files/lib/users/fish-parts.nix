{ pkgs }:
{
  interactiveShellInitCommon = ''
    # fix strange $TERM
    if test $TERM = "xterm-termite" -o $TERM = "termite"
      set -x TERM "xterm-256color"
    end

    # Enable Pure theme
    if test $THEME_PURE = true
      source ${pkgs.fish-theme-pure}/conf.d/pure.fish
      set fish_function_path ${pkgs.fish-theme-pure} $fish_function_path
      set pure_separate_prompt_on_error true
    end
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
