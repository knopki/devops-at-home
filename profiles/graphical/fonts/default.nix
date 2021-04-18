{ pkgs, ... }: {
  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      corefonts
      font-awesome_4
      noto-fonts
    ];
    fontconfig = {
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        monospace = [ "Noto Sans Mono" ];
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
      };
      localConf = ''
        <?xml version="1.0" ?>
        <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
        <fontconfig>
          <!-- This adds Noto Color Emoji as a final fallback font for the default font families. -->
          <match>
            <test name="family"><string>sans-serif</string></test>
            <edit name="family" mode="prepend" binding="weak">
              <string>Noto Color Emoji</string>
            </edit>
          </match>

          <match>
            <test name="family"><string>serif</string></test>
            <edit name="family" mode="prepend" binding="weak">
              <string>Noto Color Emoji</string>
            </edit>
          </match>

          <!-- Use Noto Color Emoji when other popular fonts are being specifically requested. -->
          <match target="pattern">
              <test qual="any" name="family"><string>Apple Color Emoji</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
          </match>

          <match target="pattern">
              <test qual="any" name="family"><string>Segoe UI Emoji</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
          </match>

          <match target="pattern">
              <test qual="any" name="family"><string>Segoe UI Symbol</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
          </match>

          <match target="pattern">
              <test qual="any" name="family"><string>Android Emoji</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
          </match>

          <match target="pattern">
              <test qual="any" name="family"><string>Twitter Color Emoji</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
          </match>

          <match target="pattern">
              <test qual="any" name="family"><string>Twemoji</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
          </match>

          <match target="pattern">
              <test qual="any" name="family"><string>Twemoji Mozilla</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
          </match>

          <match target="pattern">
              <test qual="any" name="family"><string>TwemojiMozilla</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
          </match>

          <match target="pattern">
              <test qual="any" name="family"><string>EmojiTwo</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
          </match>

          <match target="pattern">
              <test qual="any" name="family"><string>Emoji Two</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
          </match>

          <match target="pattern">
              <test qual="any" name="family"><string>EmojiSymbols</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
          </match>

          <match target="pattern">
              <test qual="any" name="family"><string>Symbola</string></test>
              <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
          </match>
        </fontconfig>
      '';
    };
  };
}
