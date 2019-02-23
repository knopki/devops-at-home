{ config, pkgs, lib, username, ...}:
let
  selfHM = config.home-manager.users.root;
  fishParts = import ../fish-parts.nix { inherit pkgs; };
in with builtins;
{
  programs.fish = {
    interactiveShellInit = ''
      ${fishParts.interactiveShellInitCommon}
    '';
  };
}
