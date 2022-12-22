channels: final: prev: {

  __dontExport = true; # overrides clutter up actual creations

  # inherit (channels.latest) something;

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

  nodePackages = prev.nodePackages // {
    pyright = channels.latest.nodePackages.pyright;
  };
}
