# Better defaults for OpenSSH
{
  lib,
  config,
  ...
}:
let
  inherit (lib.modules) mkDefault mkForce mkIf;
  inherit (lib.options) mkEnableOption;
  cfg = config.custom.openssh;
in
{
  options.custom.openssh.enable = mkEnableOption "Enable openssh profile";

  config = mkIf cfg.enable {
    services.openssh = {
      settings.X11Forwarding = mkDefault false;
      settings.KbdInteractiveAuthentication = false;
      settings.PasswordAuthentication = false;
      settings.UseDns = false;
      # unbind gnupg sockets if they exists
      settings.StreamLocalBindUnlink = true;

      # Use key exchange algorithms recommended by `nixpkgs#ssh-audit`
      settings.KexAlgorithms = [
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
        "diffie-hellman-group16-sha512"
        "diffie-hellman-group18-sha512"
        "sntrup761x25519-sha512@openssh.com"
      ];
      # Only allow system-level authorized_keys to avoid injections.
      # We currently don't enable this when git-based software that relies on this is enabled.
      # It would be nicer to make it more granular using `Match`.
      # However those match blocks cannot be put after other `extraConfig` lines
      # with the current sshd config module, which is however something the sshd
      # config parser mandates.
      authorizedKeysFiles = mkIf (
        !config.services.gitea.enable
        && !config.services.gitlab.enable
        && !config.services.gitolite.enable
        && !config.services.gerrit.enable
        && !config.services.forgejo.enable
      ) (mkForce [ "/etc/ssh/authorized_keys.d/%u" ]);
    };
  };
}
