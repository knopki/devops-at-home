{ config, lib, pkgs, nixosConfig, ... }:
with lib;
let
  cfg = config.theme;
  template = "${nixosConfig.nix.registry.base16-shell.flake.outPath}/templates/default.mustache";
  themeFile = pkgs.runCommandLocal "hm-shell-theme" { } ''
    sed '${
      concatStrings
        ((mapAttrsToList (n: v: "s/{{${n}-hex}}/${v.hex.rgb}/;") cfg.base16.colors)
         ++ (mapAttrsToList (n: v: "s/{{${n}-hex-r}}/${v.hex.r}/;") cfg.base16.colors)
         ++ (mapAttrsToList (n: v: "s/{{${n}-hex-g}}/${v.hex.g}/;") cfg.base16.colors)
         ++ (mapAttrsToList (n: v: "s/{{${n}-hex-b}}/${v.hex.b}/;") cfg.base16.colors))
    }' ${template} > $out
  '';
in
{
  options.theme.components = {
    bash.enable = mkEnableOption "Apply theme to Bash" // { default = cfg.enable; };
    fish.enable = mkEnableOption "Apply theme to Fish" // { default = cfg.enable; };
    zsh.enable = mkEnableOption "Apply theme to Zsh" // { default = cfg.enable; };
  };

  config = mkIf (cfg.enable) (mkMerge [
    (mkIf (cfg.components.bash.enable) {
      programs.bash.initExtra = mkBefore ''
        sh ${themeFile}
      '';
    })

    (mkIf (cfg.components.fish.enable) {
      programs.fish.interactiveShellInit = mkBefore ''
        sh ${themeFile}
      '';
      programs.fish.plugins = mkIf (cfg.preset == "dracula") [
        {
          name = "dracula";
          src = nixosConfig.nix.registry.dracula-fish.flake.outPath;
        }
      ];
    })

    (mkIf (cfg.components.zsh.enable) {
      programs.zsh.initExtra = mkBefore ''
        sh ${themeFile}
      '';
    })
  ]);
}
