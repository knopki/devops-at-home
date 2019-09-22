{ stdenv, fetchFromGitHub, rustPlatform, gtk3, atk, pango, cairo, gdk_pixbuf, glib, gobjectIntrospection }:

with rustPlatform;

buildRustPackage rec {
  name = "neovim-gtk-${version}";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "daa84";
    repo = "neovim-gtk";
    rev = "6a7804c6e797142724548b09109cf2883cd6f08c";
    sha256 = "0idn0j41h3bvyhcq2k0ywwnbr9rg9ci0knphbf7h7p5fd4zrfb30";
  };

  propagatedBuildInputs =
    [ gtk3 gdk_pixbuf atk pango cairo glib gobjectIntrospection ];

  cargoSha256 = "0rnmfqdc6nwvbhxpyqm93gp7zr0ccj6i94p9zbqy95972ggp02df";

  meta = with stdenv.lib; {
    description =
      "GTK ui for neovim written in rust using gtk-rs bindings. With ligatures support.";
    homepage = "https://github.com/daa84/neovim-gtk";
    license = with licenses; [ gpl3 ];
    platforms = platforms.all;
  };
}
