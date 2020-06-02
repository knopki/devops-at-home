{ config, nixosConfig, lib, pkgs, ... }:
with lib;
{
  imports = import ./list.nix;

  knopki = {
    fish = {
      colorizeMan = true;
      defaultFuncs = true;
      fixTerm = true;
      loadProfile = true;
      lsColors = true;
      pureTheme = true;
      interactiveShellInit."99-binds" = ''
        bind --user \cw backward-kill-word # Ctrl-W
        bind --user \e\[3\;5~ kill-word  # Ctrl-Delete
      '';
    };
  };
}
