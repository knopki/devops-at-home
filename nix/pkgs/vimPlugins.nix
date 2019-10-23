{ vimUtils, fetchFromGitHub, lib, overrides ? (self: super: {}) }:
let
  sources = import ../sources.nix;
  packages = (
    self: {
      vim-bbye = vimUtils.buildVimPluginFrom2Nix {
        pname = "vim-bbye";
        version = sources.vim-bbye.version;
        src = sources.vim-bbye;
      };
      vim-sideways = vimUtils.buildVimPluginFrom2Nix {
        pname = "vim-sideways";
        version = sources.vim-sideways.version;
        src = sources.vim-sideways;
      };
    }
  );
in
lib.fix' (lib.extends overrides packages)
