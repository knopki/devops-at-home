self: super: {
  unstable = import ((import ../lib/fetchGHTarball.nix) {
    owner = "NixOS";
    repo = "nixpkgs-channels";
    rev = "19eedaf867da3155eec62721e0c8a02895aed74b"; # 2019-02-25
    sha256 = "06k0hmdn8l1wiirfjcym86pn9rdi8xyfh1any6vgb5nbx87al515";
  }) {
    config.allowUnfree = true;
  };
}
