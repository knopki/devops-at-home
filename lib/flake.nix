{ lib, ... }:
let
  inherit (builtins) fromJSON readFile;
  inherit (lib) getAttrs fetchFromGithub;

  flakeLock = fromJSON (readFile ../flake.lock);
in
rec {
  getLockNode = name: flakeLock.nodes."${name}";

  getNodeGithubAttrs = name: let
    node = getLockNode name;
  in
    (getAttrs [ "owner" "repo" "rev" ] node.locked) // { hash = node.locked.narHash; };

  fetchInputFromGithub = name: fetchFromGithub (getNodeGithubAttrs name);
}
