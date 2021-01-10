final: prev: rec {
  dracula-theme-icons = prev.callPackage ./dracula-icon-theme.nix {};
  kube-score = prev.callPackage ./kube-score {};
  kustomize1 = prev.callPackage ./kustomize1 {};
  sway-scripts = prev.callPackage ./sway-scripts {};
  winbox = winbox-bin;
  winbox-bin = prev.callPackage ./winbox {};
}
