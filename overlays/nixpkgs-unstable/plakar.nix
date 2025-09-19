final: prev:
let
  p = prev.nixpkgsUnstable;
in
{
  plakar = prev.callPackage p.plakar.override { };
}
