final: prev: {
  ledger-live-desktop = prev.ledger-live-desktop.overrideAttrs (o: rec {
    pname = "ledger-live-desktop";
    version = "2.25.1";
    name = "${pname}-${version}";
    src = prev.fetchurl {
      url = "https://github.com/LedgerHQ/${pname}/releases/download/${version}/${name}-linux-x86_64.AppImage";
      sha256 = "sha256-HiKHuJHv8BKgP5+vwHNeXhTgGK3Akk1NrDekeHm4RQs=";
    };
  });
}
