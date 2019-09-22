{ config, pkgs, lib, ... }:

with lib;

{
  options = { local.general.fonts.enable = mkEnableOption "Fonts Options"; };

  config = mkIf config.local.general.fonts.enable {
    fonts = {
      enableFontDir = true;
      fonts = with pkgs; [
        emojione
        fira-code-nerd
        font-awesome_4
        noto-fonts
        noto-fonts-emoji
      ];
      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [
            "Noto Color Emoji"
            "EmojiOne Color"
            "Noto Emoji"
            "Noto Sans Mono"
          ];
          sansSerif =
            [ "Noto Color Emoji" "EmojiOne Color" "Noto Emoji" "Noto Sans" ];
          serif =
            [ "Noto Color Emoji" "EmojiOne Color" "Noto Emoji" "Noto Serif" ];
        };
        penultimate.enable = true;
        ultimate.enable = true;
        localConf = ''
          <?xml version="1.0" ?>
          <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
          <fontconfig>
            <!-- there we fix huge icons -->
            <match target="scan">
              <test name="family">
                <string>Noto Color Emoji</string>
              </test>
              <edit name="scalable" mode="assign">
                <bool>false</bool>
              </edit>
            </match>
          </fontconfig>
        '';
      };
      enableDefaultFonts = true;
    };
  };
}
