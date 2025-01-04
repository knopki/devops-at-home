{
  lib,
  haumea ? null,
  ...
}:
let
  lock = builtins.fromJSON (builtins.readFile ../flake.lock);
  flake-compat = fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
    sha256 = lock.nodes.flake-compat.locked.narHash;
  };
  self = import flake-compat {
    src = ../.;
  };
  haumeaLib = if (haumea != null) then haumea else self.defaultNix.inputs.haumea;
in
haumeaLib.lib.load {
  src = ./src;
  inputs = {
    inherit lib;
    haumea = haumeaLib;
  };
}
