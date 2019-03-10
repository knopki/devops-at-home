self: super: {
  unstable = import ((import ../lib/fetchGHTarball.nix) {
    owner = "NixOS";
    repo = "nixpkgs-channels";
    rev = "34aa254f9ebf5899636a9927ceefbc9df80230f4"; # 2019-03-10
    sha256 = "1ajl37n7bycww9c0igigprm02g3s2bv5295v2m1p3hs74li0pyhr";
  }) {
    config.allowUnfree = true;
  };
}
