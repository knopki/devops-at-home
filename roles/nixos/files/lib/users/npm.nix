{ config, username, ... }:
let
  selfHM = config.home-manager.users."${username}";
in {
  home.file = {
    ".npmrc".text = ''
      cache="${selfHM.xdg.cacheHome}/npm"
      prefix="${selfHM.xdg.configHome}/npm"
    '';
  };
}
