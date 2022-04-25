{ lib }:
lib.makeExtensible (self:
  let
    callLibs = file: import file { inherit lib; };
  in
  {
    hex = callLibs ./hex.nix;
  })
