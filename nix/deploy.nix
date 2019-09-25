let
  fetchFromGitHub = (import <nixpkgs> {}).fetchFromGitHub;
  versions = builtins.fromJSON (builtins.readFile ./pkgs/versions.json);
  pkgs = import (fetchFromGitHub versions.nixpkgs-stable) {};
  desktopHealthChecks = [
    {
      cmd = [ "systemctl" "is-active" "--quiet" "home-manager-root.service" ];
      description = "Check Home Manager activation for root user";
    }
    {
      cmd = [ "systemctl" "is-active" "--quiet" "home-manager-sk.service" ];
      description = "Check Home Manager activation for sk user";
    }
  ];
in
{
  network = {
    inherit pkgs;
    description = "all my nixos hosts";
  };

  "root@z.alien.1984.run" = { config, ... }: {
    imports = [ ./config/alien.1984.run.nix ];
    deployment = { healthChecks = { cmd = desktopHealthChecks; }; };
  };

  "root@z.oberon.1984.run" = { config, ... }: {
    imports = [ ./config/oberon.1984.run.nix ];
    deployment = { healthChecks = { cmd = desktopHealthChecks; }; };
  };

  "root@z.panzer.1984.run" = { config, ... }: {
    imports = [ ./config/panzer.1984.run.nix ];
    deployment = { healthChecks = { cmd = desktopHealthChecks; }; };
  };
}
