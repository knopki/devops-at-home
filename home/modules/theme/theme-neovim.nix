{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkMerge mkEnableOption
    elem concatStrings concatStringsSep mapAttrsToList escape;
  cfg = config.theme;
  template = "${pkgs.base16-vim}/templates/default.mustache";
  themeFile = pkgs.runCommandLocal "hm-vim-theme" { } ''
    sed '${
      concatStrings
        ((mapAttrsToList (n: v: "s/{{${n}-hex}}/${v.hex.rgb}/;") cfg.base16.colors)
         ++ ["s/{{scheme-slug}}/${cfg.base16.name}/;"])
    }' ${template} > $out
  '';
  gfn = ''
    set gfn=${escape [ " " ] cfg.fonts.monospace.family}\ ${toString cfg.fonts.monospace.size}
  '';
in
{
  options.theme.components.neovim.enable = mkEnableOption "Apply theme to Neovim" // { default = cfg.enable; };

  config = mkIf (cfg.enable && cfg.components.neovim.enable) (mkMerge [
    (mkIf (!elem cfg.preset [ "dracula" ]) {
      programs.neovim.plugins = [
        {
          plugin = pkgs.vimPlugins.base16-vim;
          config = concatStringsSep "\n" [
            ''
              let base16colorspace=256  " Access colors present in 256 colorspace
            ''
            (builtins.readFile themeFile)
            ''
              colorscheme base16-${cfg.base16.name}
            ''
            gfn
          ];
        }
      ];
    })

    (mkIf (cfg.preset == "dracula") {
      programs.neovim.plugins = [
        {
          plugin = pkgs.vimPlugins.dracula-vim;
          config = ''
            let g:dracula_italic = 1
            let g:dracula_colorterm = 1
            let g:airline_theme='dracula'
            au VimEnter * colorscheme dracula

            ${gfn}
          '';
        }
      ];
    })
  ]);
}
