final: prev: {
  # keep sources this first
  sources = prev.callPackage (import ./_sources/generated.nix) {};
  # then, call packages with `final.callPackage`

  # applications
  manta-signer = final.callPackage ./applications/crypto/manta-signer.nix {};
  marvin = final.callPackage ./applications/misc/marvin.nix {};
  kubectl-cert-manager = final.callPackage ./applications/networking/cluster/kubectl-cert-manager.nix {};
  wgcf = final.callPackage ./applications/networking/wgcf.nix {};

  # data
  base16-default-schemes = final.callPackage ./data/themes/base16-default-schemes.nix {};
  base16-dracula-scheme = final.callPackage ./data/themes/base16-dracula-scheme.nix {};
  base16-shell = final.callPackage ./data/themes/base16-shell.nix {};
  base16-textmate = final.callPackage ./data/themes/base16-textmate.nix {};
  base16-tmux = final.callPackage ./data/themes/base16-tmux.nix {};
  base16-vim = final.callPackage ./data/themes/base16-vim.nix {};
  base16-waybar = final.callPackage ./data/themes/base16-waybar.nix {};
  dracula-alacritty = final.callPackage ./data/themes/dracula-alacritty.nix {};
  dracula-icon-theme = final.callPackage ./data/icons/dracula-icon-theme.nix {};
  dracula-wofi = final.callPackage ./data/themes/dracula-wofi.nix {};
  dracula-zathura = final.callPackage ./data/themes/dracula-zathura.nix {};
  ls-colors = final.callPackage ./data/themes/ls-colors.nix {};

  # misc
  vscode-extensions =
    prev.vscode-extensions
    // (import ./misc/vscode-extensions.nix {inherit (final) fetchurl vscode-utils;});

  # tools
  sway-scripts = final.callPackage ./tools/wayland/sway-scripts {};

  # shells
  fishPlugins =
    prev.fishPlugins
    // {
      dracula-fish = final.callPackage ./shells/fish/plugins/dracula-fish.nix {};
    };

  cronosd = final.callPackage ./cronosd.nix {};
}
