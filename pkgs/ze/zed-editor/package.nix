{ nixpkgsUnstable, ... }:
nixpkgsUnstable.zed-editor.fhsWithPackages (
  ps: with ps; [
    openssl
  ]
)
