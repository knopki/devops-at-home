# This file is needed only to backward compatibility
# for `update-packages` package. Do not use!
{
  pkgs ? import <nixpkgs> { },
  ...
}:
pkgs.mkShell { }
