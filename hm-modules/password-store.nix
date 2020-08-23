{ config, lib, pkgs, ... }:
with lib;
{
  options.knopki.password-store = {
    enable = mkEnableOption "password-store configuration";
  };

  config = mkIf config.knopki.password-store.enable {
    home.packages = with pkgs; [ gopass ];
    programs = {
      git = {
        extraConfig.credential.helper =
          "!${pkgs.gopass}/bin/gopass git-credential $@";
      };
      password-store = {
        enable = true;
        package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
        settings = {
          PASSWORD_STORE_KEY = config.programs.gpg.settings.default-key;
        };
      };
    };
    services = {
      password-store-sync.enable = true;
    };
  };
}
