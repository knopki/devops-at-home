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
      ];
      fontconfig = {
        enable = true;
        defaultFonts = {
          emoji = [ "Noto Color Emoji" "EmojiOne Color" ];
          monospace = [ "Noto Sans Mono" ];
          sansSerif = [ "Noto Sans" ];
          serif = [ "Noto Serif" ];
        };
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
    };
  };
}
