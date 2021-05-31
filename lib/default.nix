{ lib }:
lib.makeExtensible (self:
  let
    callLibs = file: import file { inherit lib; ourLib = self; };
  in
  {
    hex = callLibs ./hex.nix;
  })
