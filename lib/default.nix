{ lib, ... }:
{
  hex = import ./hex.nix { inherit lib; };
  nixpkgsPolicies = import ./nixpkgs-policies.nix { inherit lib; };
  sshPubKeys = import ./ssh-pubkeys.nix;
  systemd = import ./systemd.nix { inherit lib; };
}
