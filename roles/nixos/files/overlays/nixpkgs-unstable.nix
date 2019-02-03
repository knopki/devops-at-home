self: super: {
  unstable = import ((import ../lib/fetchGHTarball.nix) {
    owner = "NixOS";
    repo = "nixpkgs-channels";
    rev = "2d6f84c1090ae39c58dcec8f35a3ca62a43ad38c"; # 2019-02-07
    sha256 = "0l8b51lwxlqc3h6gy59mbz8bsvgc0q6b3gf7p3ib1icvpmwqm773";
  }) {
    config.allowUnfree = true;
  };
}
