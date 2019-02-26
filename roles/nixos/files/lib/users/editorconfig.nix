{ lib, ... }:
{
  home.file = {
    ".editorconfig".text = builtins.concatStringsSep "\n" [
      (lib.generators.toKeyValue {} {
        # top-most EditorConfig file
        root = true;
      })
      (lib.generators.toINI {} {
        # Unix-style newlines with a newline ending every file
        "*" = {
          end_of_line = "lf";
          insert_final_newline = true;
          trim_trailing_whitespace = true;
          charset = "utf-8";
          indent_style = "space";
          indent_size = 2;
        };
      })
    ];

  };
}
