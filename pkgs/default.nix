final: prev: {
  # applications
  steamcompmgr = prev.callPackage ./applications/window-managers/steamcompmgr.nix { };

  # data
  base16-default-schemes = prev.callPackage ./data/themes/base16-default-schemes.nix { };
  base16-dracula-scheme = prev.callPackage ./data/themes/base16-dracula-scheme.nix { };
  base16-shell = prev.callPackage ./data/themes/base16-shell.nix { };
  base16-textmate = prev.callPackage ./data/themes/base16-textmate.nix { };
  base16-tmux = prev.callPackage ./data/themes/base16-tmux.nix { };
  base16-vim = prev.callPackage ./data/themes/base16-vim.nix { };
  base16-waybar = prev.callPackage ./data/themes/base16-waybar.nix { };
  dracula-alacritty = prev.callPackage ./data/themes/dracula-alacritty.nix { };
  dracula-icon-theme = prev.callPackage ./data/icons/dracula-icon-theme.nix { };
  dracula-wofi = prev.callPackage ./data/themes/dracula-wofi.nix { };
  dracula-zathura = prev.callPackage ./data/themes/dracula-zathura.nix { };
  ls-colors = prev.callPackage ./data/themes/ls-colors.nix { };

  # desktops
  krohnkite = prev.callPackage ./desktops/plasma-5/krohnkite.nix { };

  # misc
  vscode-extensions = prev.vscode-extensions //
    (import ./misc/vscode-extensions.nix { inherit (prev) fetchurl vscode-utils; });

  # tools
  sway-scripts = prev.callPackage ./tools/wayland/sway-scripts { };
  winbox-bin = prev.callPackage ./tools/networking/winbox.nix { };

  # shells
  fishPlugins = prev.fishPlugins // {
    dracula-fish = prev.callPackage ./shells/fish/plugins/dracula-fish.nix { };
    fish-kubectl-completions = prev.callPackage ./shells/fish/plugins/fish-kubectl-completions.nix { };
  };
}
