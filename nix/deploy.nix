let
  fetchFromGitHub = (import <nixpkgs> { }).fetchFromGitHub;
  versions = builtins.fromJSON (builtins.readFile ./pkgs/versions.json);
  pkgs = import (fetchFromGitHub versions.nixpkgs-stable) { };
in {
  network = {
    inherit pkgs;
    description = "all my nixos hosts";
  };

  "root@z.alien.1984.run" = { config, ... }: {
    imports = [ ./config/alien.1984.run.nix ];
  };

  "root@z.panzer.1984.run" = { config, ... }: {
    imports = [ ./config/panzer.1984.run.nix ];
  };
}
