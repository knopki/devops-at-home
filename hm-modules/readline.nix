{ config, lib, pkgs, ... }:
with lib; {
  options.knopki.readline.enable = mkEnableOption "setup readline in .inputrc";

  config = mkIf config.knopki.readline.enable {
    programs.readline = {
      enable = true;
      bindings = {
        # These allow you to use ctrl+left/right arrow keys to jump the cursor over words
        "\e[5C" = "forward-word";
        "\e[5D" = "backward-word";
      };
      variables = {
        # do not make noise
        bell-style = "none";
      };
    };
  };
}
