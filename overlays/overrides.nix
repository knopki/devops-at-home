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

  # plasma5Packages = prev.plasma5Packages // {
  #   plasma5 = prev.plasma5Packages.plasma5 // {
  #     thirdParty = prev.plasma5Packages.plasma5.thirdParty // {
  #       bismuth = channels.latest.plasma5Packages.plasma5.thirdParty.bismuth;
  #     };
  #   };
  # };

  nodePackages = prev.nodePackages // {
    pyright = channels.latest.nodePackages.pyright;
  };
}
