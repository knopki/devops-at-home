{ config, lib, pkgs, nixosConfig, ... }:
with lib;
let
  cfg = config.theme;
in
{
  options.theme.components.wofi.enable = mkEnableOption "Apply theme to Wofi" // { default = cfg.enable; };

  config = mkIf (cfg.enable && cfg.components.wofi.enable) (mkMerge [
    (mkIf (!elem cfg.preset [ "dracula" ]) {
      xdg.configFile."wofi/style.css".text = mkBefore (with cfg.base16.colors; ''
        window {
          background-color: #${base00.hex.rgb};
          color: #${base05.hex.rgb};
        }

        #entry:nth-child(odd) {
          background-color: #${base00.hex.rgb};
        }

        #entry:nth-child(even) {
          background-color: #${base01.hex.rgb};
        }

        #entry:selected {
          background-color: #${base02.hex.rgb};
        }

        #input {
          background-color: #${base01.hex.rgb};
          color: #${base04.hex.rgb};
          border-color: #${base02.hex.rgb};
        }

        #input:focus {
          border-color: #${base0A.hex.rgb};
        }
      '');
    })

    (mkIf (cfg.preset == "dracula") {
      xdg.configFile."wofi/style.css".text = mkBefore (builtins.readFile
        "${nixosConfig.nix.registry.dracula-wofi.flake.outPath}/style.css");
    })
  ]);
}
