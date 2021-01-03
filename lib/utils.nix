{ lib, ... }:
with lib;
let
  inherit (builtins) div readDir;
in
rec {
  # mapFilterAttrs ::
  #   (name -> value -> bool )
  #   (name -> value -> { name = any; value = any; })
  #   attrs
  mapFilterAttrs = seive: f: attrs: filterAttrs seive (mapAttrs' f attrs);

  recImportHosts = { dir, _import }:
    mapFilterAttrs (_: v: v != null)
      (
        n: v:
          let
            parts = splitString "." n;
          in
          if v == "regular" && hasSuffix ".nix" n && (length parts) == 3
          then
            let
              name = elemAt parts 0;
              system = elemAt parts 1;
            in
            nameValuePair (name) (_import name system)
          else nameValuePair ("") (null)

      )
      (readDir dir);

  # @author Robert Helgesson
  # @license MIT
  # toHex2 :: int -> string
  toHex2 =
    let
      hex = [ "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "a" "b" "c" "d" "e" "f" ];
      hexVal = elemAt hex;
    in
    n: hexVal (mod 16 n) + hexVal (mod 16 (div n 16));

  # @author Robert Helgesson
  # @license MIT
  # fromHex :: string -> number
  fromHex =
    let
      hexes = {
        "0" = 0;
        "1" = 1;
        "2" = 2;
        "3" = 3;
        "4" = 4;
        "5" = 5;
        "6" = 6;
        "7" = 7;
        "8" = 8;
        "9" = 9;
        "A" = 10;
        "B" = 11;
        "C" = 12;
        "D" = 13;
        "E" = 14;
        "F" = 15;
        "a" = 10;
        "b" = 11;
        "c" = 12;
        "d" = 13;
        "e" = 14;
        "f" = 15;
      };
    in
    v: foldl' (acc: x: acc * 16 + hexes.${x}) 0 (stringToCharacters v);
}
