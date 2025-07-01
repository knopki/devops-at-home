{ lib, ... }:
{
  hex = import ./hex.nix { inherit lib; };
  sshPubKeys = import ./ssh-pubkeys.nix;
}
