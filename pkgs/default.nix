final: prev: rec {
  kube-score = prev.callPackage ./kube-score {};
  kustomize1 = prev.callPackage ./kustomize1 {};
  vimPlugins = prev.vimPlugins // prev.recurseIntoAttrs (prev.callPackages ./vimPlugins.nix {});
  winbox = winbox-bin;
  winbox-bin = prev.callPackage ./winbox {};
}
