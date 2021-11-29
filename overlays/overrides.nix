channels: final: prev: {

  __dontExport = true; # overrides clutter up actual creations

  inherit (channels.latest)
    anytype
    brave
    cachix
    dhall
    discord
    kalker
    manix
    neovim
    neovim-unwrapped
    nixpkgs-fmt
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

  ledger-live-desktop =
    let
      pname = "ledger-live-desktop";
      version = "2.35.2";
      name = "${pname}-${version}";
      src = prev.fetchurl {
        url = "https://github.com/LedgerHQ/${pname}/releases/download/v${version}/${pname}-${version}-linux-x86_64.AppImage";
        hash = "sha256-VJr1H6YcPtCzm6FeFA+rNANvYUQ3wZQalI9RdSv68cI=";
      };
    in
    channels.latest.ledger-live-desktop.override { fetchurl = { ... }: src; };
}
