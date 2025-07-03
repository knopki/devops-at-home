_final: prev:
let
  p = prev.nixpkgsUnstable;
in
{
  anytype = prev.callPackage p.anytype.override {
    anytype-heart = p.anytype-heart;
  };
}
