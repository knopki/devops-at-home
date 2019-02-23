{ pkgs }:
{
  interactiveShellInitCommon = ''
    # fix strange $TERM
    if test $TERM = "xterm-termite" -o $TERM = "termite"
      set -x TERM "xterm-256color"
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