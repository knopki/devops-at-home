{ config, pkgs, username, lib, ...}:
let
  selfHM = config.home-manager.users."${username}";
  fishParts = import ../fish-parts.nix { inherit pkgs; };
in with builtins;
{
  programs.fish = {
    interactiveShellInit = ''
      # Enable theme Pure
      set THEME_PURE true

      ${fishParts.interactiveShellInitCommon}
    '';

    shellInit = ''
      ${fishParts.shellInitCommon}
    '';
  };
}
