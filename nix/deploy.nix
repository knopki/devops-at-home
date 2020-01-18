let
  pkgs = import (import ./sources.nix).nixpkgs {};
  hmHC = [
    {
      cmd = [ "systemctl" "is-active" "--quiet" "home-manager-root.service" ];
      description = "Check Home Manager activation for root user";
    }
    {
      cmd = [ "systemctl" "is-active" "--quiet" "home-manager-sk.service" ];
      description = "Check Home Manager activation for sk user";
    }
  ];
  jupiterHC = [
    {
      cmd = [ "systemctl" "is-active" "--quiet" "apcupsd.service" ];
      description = "Check apcupsd service";
    }
    {
      cmd = [ "systemctl" "is-active" "--quiet" "hd-idle.service" ];
      description = "Check hd-idle service";
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
    deployment = {
      healthChecks = { cmd = hmHC; };
      substituteOnDestination = true;
    };
  };

  "root@z.jupiter.1984.run" = { config, ... }: {
    imports = [ ./config/jupiter.1984.run.nix ];
    deployment = {
      healthChecks = { cmd = hmHC ++ jupiterHC; };
    };
  };

  "root@z.oberon.1984.run" = { config, ... }: {
    imports = [ ./config/oberon.1984.run.nix ];
    deployment = {
      healthChecks = { cmd = hmHC; };
      substituteOnDestination = true;
    };
  };

  "root@z.panzer.1984.run" = { config, ... }: {
    imports = [ ./config/panzer.1984.run.nix ];
    deployment = {
      healthChecks = { cmd = hmHC; };
      substituteOnDestination = true;
    };
  };
}
