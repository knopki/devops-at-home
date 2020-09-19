final: prev: let
  flakeUtils = import ../lib/flake.nix { lib = prev.lib; };
  nixpkgs = import (
    prev.fetchFromGitHub
      (flakeUtils.getNodeGithubAttrs "nixpkgs-unstable")
  ) { inherit (prev) config system; };
  rofi-unwrapped = prev.rofi-unwrapped.overrideAttrs (
    o: rec {
      version = "1.6.0-dev";
      name = "rofi-wayland-unwrapped-${version}";
      src = prev.fetchFromGitHub {
        owner = "lbonn";
        repo = "rofi";
        rev = "f01397106598ac154dbfeb2b6b458924c62be5ac";
        sha256 = "sha256-PYfbZR0rEHXi0O/ru1QB3+b+99P+GkZ1RYcMtqI2mmE=";
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
  clippy = nixpkgs.clippy;
  dockerfile-language-server-nodejs = nixpkgs.nodePackages.dockerfile-language-server-nodejs;
  gopls = nixpkgs.gopls;
  grimshot = nixpkgs.sway-contrib.grimshot;
  hunspellDicts = nixpkgs.hunspellDicts;
  nerdfonts = nixpkgs.nerdfonts;
  noto-fonts-emoji = nixpkgs.noto-fonts-emoji;
  pass = prev.pass.override { waylandSupport = true; };
  pyright = nixpkgs.nodePackages.pyright;
  rofi = nixpkgs.rofi.override {
    inherit rofi-unwrapped;
    plugins = with nixpkgs; [ rofi-emoji rofi-calc ];
  };
  sway-inactive-windows-transparency = nixpkgs.sway-contrib.inactive-windows-transparency;
  swaylock-effects = nixpkgs.swaylock-effects;
  xdg-desktop-portal-wlr = nixpkgs.xdg-desktop-portal-wlr;
  yaml-language-server = nixpkgs.nodePackages.yaml-language-server;
}
