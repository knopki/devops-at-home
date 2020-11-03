final: prev:
let
  flakeUtils = import ../lib/flake.nix { lib = prev.lib; };
  nixpkgs = import
    (
      prev.fetchFromGitHub
        (flakeUtils.getNodeGithubAttrs "nixpkgs-unstable")
    )
    { inherit (prev) config system; };
  rofi-unwrapped = prev.rofi-unwrapped.overrideAttrs (
    o: rec {
      version = "1.6.0";
      name = "rofi-wayland-unwrapped-${version}";
      src = prev.fetchFromGitHub {
        owner = "lbonn";
        repo = "rofi";
        rev = "12f4e3a1cb0440b9efe902741bd8a92d4ede4245";
        sha256 = "sha256-zqr1vbikJuKhKrWVnsQ/TBSbRyYbbiF7AtS0nuI0ors=";
        fetchSubmodules = true;
      };

      nativeBuildInputs = with prev; [ meson pkgconfig cmake ];
      buildInputs = with prev; o.buildInputs ++ [
        ninja
        wayland
        wayland-protocols
      ];
    }
  );
in
{
  inherit rofi-unwrapped;
  pass = prev.pass.override { waylandSupport = true; };
  rofi = prev.rofi.override {
    inherit rofi-unwrapped;
    plugins = with prev; [ rofi-emoji rofi-calc ];
  };
}
