{ config, pkgs, username, lib, ...}:
let
  selfHM = config.home-manager.users."${username}";
in with builtins;
{
  programs.fish = {
    interactiveShellInit = ''
      fix_term # setup terminal
      activate_pure_theme # Enable theme Pure
      colorize_man_pages # Colored man pages
    '';

    shellInit = ''
      activate_fenv # activate fenv command
      load_profile # load profile with fenv
    '';
  };
}
