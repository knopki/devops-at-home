{ config, lib, pkgs, ... }:

with lib;

let
  browsers = [ "chrome" "chromium" "firefox" "vivaldi" "brave" ];
  mkChromiumFiles = dir: {
    "${dir}/com.github.browserpass.native.json".source =
      "${pkgs.browserpass}/lib/browserpass/hosts/chromium/com.github.browserpass.native.json";
    "${dir}/../policies/managed/com.github.browserpass.native.json".source =
      "${pkgs.browserpass}/lib/browserpass/policies/chromium/com.github.browserpass.native.json";
  };
in {
  disabledModules = [ "programs/browserpass.nix" ];
  options = {
    programs.browserpass = {
      enable = mkEnableOption "the browserpass extension host application";

      browsers = mkOption {
        type = types.listOf (types.enum browsers);
        default = browsers;
        example = [ "firefox" ];
        description = "Which browsers to install browserpass for";
      };
    };
  };

  config = mkIf config.programs.browserpass.enable {
    home.file = foldl' (a: b: a // b) { } (concatMap (x:
      with pkgs.stdenv;
      if x == "chrome" then
        let
          dir = if isDarwin then
            "Library/Application Support/Google/Chrome/NativeMessagingHosts"
          else
            ".config/google-chrome/NativeMessagingHosts";
        in [(mkChromiumFiles dir)]
      else if x == "chromium" then
        let
          dir = if isDarwin then
            "Library/Application Support/Chromium/NativeMessagingHosts"
          else
            ".config/chromium/NativeMessagingHosts";
        in [(mkChromiumFiles dir)]
      else if x == "firefox" then
        let
          dir = if isDarwin then
            "Library/Application Support/Mozilla/NativeMessagingHosts"
          else
            ".mozilla/native-messaging-hosts";
        in [{
          "${dir}/com.github.browserpass.native.json".source =
            "${pkgs.browserpass}/lib/browserpass/hosts/firefox/com.github.browserpass.native.json";
        }]
      else if x == "vivaldi" then
        let
          dir = if isDarwin then
            "Library/Application Support/Vivaldi/NativeMessagingHosts"
          else
            ".config/vivaldi/NativeMessagingHosts";
        in [(mkChromiumFiles dir)]
      else if x == "brave" then
        let
          dir = if isDarwin then
            "Library/Application Support/BraveSoftware/Brave-Browser/NativeMessagingHosts"
          else
            ".config/BraveSoftware/Brave-Browser/NativeMessagingHosts";
        in [(mkChromiumFiles dir)]
      else
        throw "unknown browser ${x}") config.programs.browserpass.browsers);
  };
}
