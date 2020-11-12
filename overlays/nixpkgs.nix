final: prev: {
  # TODO: https://github.com/NixOS/nixpkgs/issues/83096
  tor-browser-bundle-bin = prev.tor-browser-bundle-bin.overrideAttrs (o: {
    meta = o.meta // { broken = false; };
  });
}
