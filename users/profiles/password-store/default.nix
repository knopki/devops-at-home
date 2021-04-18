{ config, options, pkgs, lib, ... }:
let
  inherit (lib) mkDefault mkIf;
in
{

  home.packages = with pkgs; [ qtpass ];
  programs = {
    git = {
      # NOTE: https://github.com/languitar/pass-git-helper
      extraConfig.credential.helper =
        "!${pkgs.gitAndTools.pass-git-helper}/bin/pass-git-helper $@";
    };
    password-store = {
      enable = true;
      package = pkgs.pass.withExtensions (
        ext: with ext; [
          pass-audit
          pass-checkup
          pass-genphrase
          pass-otp
          pass-update
        ]
      );
    };
  };

  services = mkIf (options ? services.password-store-sync) {
    # NOTE: set $SSH_AUTH_SOCK in systemd
    password-store-sync.enable = mkDefault true;
  };

  systemd.user.services.password-store-sync = {
    Service.ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
  };
}
