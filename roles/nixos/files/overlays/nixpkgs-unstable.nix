self: super: {
  unstable = import ((import ../lib/fetchGHTarball.nix) {
    owner = "NixOS";
    repo = "nixpkgs-channels";
    rev = "5d3fd3674a66c5b1ada63e2eace140519849c967"; # 2019-03-12
    sha256 = "1ajl37n7bycww9c0igigprm02g3s2bv5295v2m1p3hs74li0pyhr";
  }) {
    config.allowUnfree = true;
  };
}
