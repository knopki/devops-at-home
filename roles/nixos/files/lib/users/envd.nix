{ config, envd, lib, username, ...}:
with lib;
let
  selfHM = config.home-manager.users."${username}";
  rootDirPath = "${config.home-manager.users."${username}".xdg.configHome}/environment.d";

  mapToText = mapAttrs
    (file: envAttrs:
      generators.toKeyValue {} envAttrs);
in {
  home.file = mkMerge (
    attrValues (
      mapAttrs
        (file: text: { "${rootDirPath}/${file}.conf".text = text; })
        (mapToText envd)));
}
