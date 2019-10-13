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
      vim-sideways = vimUtils.buildVimPluginFrom2Nix {
        pname = "vim-sideways";
        version = "2019-05-23";
        src = fetchFromGitHub {
          owner = "AndrewRadev";
          repo = "sideways.vim";
          rev = "17c03c59913f76bbdede07b8f9d4a1f163d9b2f2";
          sha256 = "1f1s5i8rrgvz1rpyy7lnhrid05ps9fnqryyqpz2nfq0aggws93sr";
        };
      };
    }
  );
in
lib.fix' (lib.extends overrides packages)
