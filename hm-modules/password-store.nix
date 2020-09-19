{ config, lib, pkgs, ... }:
with lib;
{
  options.knopki.password-store = {
    enable = mkEnableOption "password-store configuration";
  };

  config = mkIf config.knopki.password-store.enable {
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
        settings = {
          PASSWORD_STORE_KEY = config.programs.gpg.settings.default-key;
        };
      };
    };
    services = {
      # NOTE: set $SSH_AUTH_SOCK in systemd
      password-store-sync.enable = true;
    };
  };
}
