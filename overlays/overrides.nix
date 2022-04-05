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
  #   bismuth = channels.latest.plasma5Packages.plasma5.thirdParty.bismuth.overrideAttrs (o: rec {
  #     version = "3.1.0";
  #     src = prev.fetchFromGitHub {
  #       owner = "Bismuth-Forge";
  #       repo = o.pname;
  #       rev = "release-v${version}";
  #       sha256 = "sha256-Wx1D05xGcRZgvUn/Vtxex/qReifCYCXGUjH0IhsiHeE=";
  #     };
  #   });
  # };

  nodePackages = prev.nodePackages // {
    pyright = channels.latest.nodePackages.pyright;
  };
}
