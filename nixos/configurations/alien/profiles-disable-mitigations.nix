{ lib, ... }:
let
  inherit (lib.strings) splitString;
in
{
  boot.kernelParams = splitString " " ''
    ibrs noibpb nopti nospectre_v2 nospectre_v1 l1tf=off nospec_store_bypass_disable no_stf_barrier mds=off tsx=on tsx_async_abort=off mitigations=off
  '';
}
