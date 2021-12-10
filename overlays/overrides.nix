channels: final: prev: {

  __dontExport = true; # overrides clutter up actual creations

  inherit (channels.latest)
    anytype
    cachix
    dhall
    discord
    manix
    rage;

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

  libsForQt5 = prev.libsForQt5 // {
    thirdParty = prev.thirdParty // {
      bismuth = channels.latest.libsForQt5.thirdParty.bismuth;
    };
  };
}
