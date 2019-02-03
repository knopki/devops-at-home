self: super: {
  nur = import ((import ../lib/fetchGHTarball.nix) {
    owner = "nix-community";
    repo = "NUR";
    rev = "4a0e5d4c442bd775ddc23e5d94d91b9a326a2aff"; # 2019-02-07
    sha256 = "0abj5sk01kmwxsbm7a44xjydmrr1yrgay3gpis7bkflhnlkx9dgd";
  }) {
    inherit super;
  };
}
