_final: prev:
let
  p = prev.nixpkgsUnstable;
in
{
  simplex-chat-desktop = prev.callPackage p.simplex-chat-desktop.override {
  };
}
