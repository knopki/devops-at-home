{ config, lib, pkgs, user, ... }:
with lib;
{
  options.local.readline = mkEnableOption "setup readline in .inputrc";

  config = mkIf config.local.readline {
    home.file = {
      ".inputrc".text = ''
        # do not make noise
        set bell-style none

        # These allow you to use ctrl+left/right arrow keys to jump the cursor over words
        "\e[5C": forward-word
        "\e[5D": backward-word
      '';
    };
  };
}
