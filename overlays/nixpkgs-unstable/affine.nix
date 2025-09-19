_final: prev:
let
  p = prev.nixpkgsUnstable;
in
{
  affine = p.affine;
}
