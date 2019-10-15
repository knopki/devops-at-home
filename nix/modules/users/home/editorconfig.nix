{ config, lib, pkgs, user, ... }:
with lib; {
  options.local.editorconfig = mkEnableOption "create root editorconfig";

  config = mkIf config.local.editorconfig {
    home.file = {
      ".editorconfig".text = concatStringsSep "\n" [
        (
          generators.toKeyValue {} {
            # top-most EditorConfig file
            root = true;
          }
        )
        (
          generators.toINI {} {
            # Unix-style newlines with a newline ending every file
            "*" = {
              end_of_line = "lf";
              insert_final_newline = true;
              trim_trailing_whitespace = true;
              charset = "utf-8";
              indent_style = "space";
              indent_size = 2;
            };
            "*.php" = {
              indent_style = "tab";
              tab_width = 4;
            };
          }
        )
      ];
    };
  };
}
