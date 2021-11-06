channels: final: prev: {

  __dontExport = true; # overrides clutter up actual creations

  inherit (channels.latest)
    anytype
    cachix
    dhall
    discord
    kalker
    ledger-live-desktop
    manix
    neovim
    neovim-unwrapped
    nixpkgs-fmt
    rage;

  inherit (channels.latest-working-vivaldi) vivaldi;
  inherit (channels.latest-working-brave) brave;

  haskellPackages = prev.haskellPackages.override {
    overrides = hfinal: hprev:
      let version = prev.lib.replaceChars [ "." ] [ "" ] prev.ghc.version;
      in
      {
        # same for haskell packages, matching ghc versions
        inherit (channels.latest.haskell.packages."ghc${version}")
          haskell-language-server;
      };
  };

}
