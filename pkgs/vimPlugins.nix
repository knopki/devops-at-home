{ lib, newScope, pkgs, vimUtils }:
with lib;
makeScope newScope (
  self: with self; let
    callPackages = lib.callPackagesWith (pkgs // self // { inherit sources; });
  in
    {
      vim-bbye = vimUtils.buildVimPluginFrom2Nix {
        pname = "vim-bbye";
        version = "1.0.1";
        src = pkgs.fetchFromGitHub {
          owner = "moll";
          repo = "vim-bbye";
          rev = "25ef93ac5a87526111f43e5110675032dbcacf56";
          sha256 = "0dlifpbd05fcgndpkgb31ww8p90pwdbizmgkkq00qkmvzm1ik4y4";
        };
        meta = {
          license = licenses.agpl3;
          platform = platforms.all;
          description = "Delete buffers and close files in Vim without closing your windows or messing up your layout. Like Bclose.vim, but rewritten and well maintained.";
          homepage = "http://www.vim.org/scripts/script.php?script_id=4664";
        };
      };
      vim-sideways = vimUtils.buildVimPluginFrom2Nix {
        pname = "vim-sideways";
        version = "0.3.0";
        src = pkgs.fetchFromGitHub {
          owner = "AndrewRadev";
          repo = "sideways.vim";
          rev = "e9de0bf7cc5f40ba507f0fddda613189f8d072eb";
          sha256 = "0zcs6w1rfg6i5rpxfpzpdgq1z18wax7sd7ij01psgzvq5h1zn56x";
        };
        meta = {
          license = licenses.mit;
          platform = platforms.all;
          description = "A Vim plugin to move function arguments (and other delimited-by-something items) left and right.";
          homepage = "http://www.vim.org/scripts/script.php?script_id=4171";
        };
      };
    }
)
