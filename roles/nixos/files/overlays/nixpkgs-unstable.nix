self: super: {
  unstable = import ((import ../lib/fetchGHTarball.nix) {
    owner = "NixOS";
    repo = "nixpkgs-channels";
    rev = "fa82ebccf66eef185d063d49a9e294a7a1e15d36"; # 2019-02-22
    sha256 = "1clkiyx8qljwq0b09l9l6qls8m0ffz059qfkraxzhmjgzj7mpkdw";
  }) {
    config.allowUnfree = true;
  };
}
