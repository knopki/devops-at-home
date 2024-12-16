{ lib, haumea, ... }:
haumea.lib.load {
  src = ./src;
  inputs = {
    inherit lib haumea;
  };
}
