# A list of well known public keys
# Originally from https://github.com/nix-community/srvos
{ lib, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.profiles.ssh-well-known-hosts;
in
{
  options.profiles.ssh-well-known-hosts.enable = mkEnableOption "Enable SSH well known hosts profile";

  config = mkIf cfg.enable {
    # Avoid TOFU MITM with github by providing their public key here.
    programs.ssh.knownHosts = {
      "github.com".hostNames = [ "github.com" ];
      "github.com".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";

      "gitlab.com".hostNames = [ "gitlab.com" ];
      "gitlab.com".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";

      "git.sr.ht".hostNames = [ "git.sr.ht" ];
      "git.sr.ht".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60";
    };
  };
}
