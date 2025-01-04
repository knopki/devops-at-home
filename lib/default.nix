{
  lib,
  haumea ? null,
  ...
}:
let
  lock = builtins.fromJSON (builtins.readFile ../flake.lock);
  haumeaSrc = fetchTarball {
    url = "https://github.com/nix-community/haumea/archive/${lock.nodes.haumea.locked.rev}.tar.gz";
    sha256 = lock.nodes.haumea.locked.narHash;
  };
  haumeaLib = if (haumea != null) then haumea else { lib = import haumeaSrc { inherit lib; }; };
in
haumeaLib.lib.load {
  src = ./src;
  inputs = {
    inherit lib;
    haumea = haumeaLib;
  };
}
