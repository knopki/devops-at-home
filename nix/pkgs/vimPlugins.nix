{ vimUtils, fetchFromGitHub, lib, overrides ? (self: super: {}) }:

let

  packages = (
    self: {
      vim-bbye = vimUtils.buildVimPluginFrom2Nix {
        pname = "vim-bbye";
        version = "2018-03-03";
        src = fetchFromGitHub {
          owner = "moll";
          repo = "vim-bbye";
          rev = "25ef93ac5a87526111f43e5110675032dbcacf56";
          sha256 = "0dlifpbd05fcgndpkgb31ww8p90pwdbizmgkkq00qkmvzm1ik4y4";
        };
      };
    }
  );
in
lib.fix' (lib.extends overrides packages)
