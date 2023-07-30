{ pkgs, lib, fetchurl, stdenv }:

let
  pname = "cronosd";
  version = "0.5.5";
  name = "cronosd-${version}";
  nameExecutable = pname;
  src = fetchurl {
    url = "https://github.com/crypto-org-chain/cronos/releases/download/v${version}-testnet/cronos_${version}-testnet_Linux_x86_64.tar.gz";
    name = "cronos_${version}-testnet_Linux_x86_64.tar.gz";
    sha256 = "sha256-P3O7HgbtiqdaIqD5xMIv9x/IE0m5XCWU4f2jDEeoans=";
  };
in
stdenv.mkDerivation rec {
  inherit src version name;

  nativeBuildInputs = [
    pkgs.autoPatchelfHook
  ];

  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    cp cronosd $out/bin/cronosd
  '';
}
