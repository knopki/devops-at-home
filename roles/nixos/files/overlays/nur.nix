self: super: {
  nur = import ((import ../lib/fetchGHTarball.nix) {
    owner = "nix-community";
    repo = "NUR";
    rev = "c7fb02c89ecf706c364d86a1ae6cf44c0f039a16"; # 2019-03-12
    sha256 = "037zadd560k0xcw54r9r560x3rwplg186v6ypgk36p3k2fzfmym8";
  }) {
    inherit super;
  };
}
