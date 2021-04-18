{ config, lib, ... }:
let
  inherit (lib) mkMerge;
  extFiles = map
    (ext: {
      "BraveSoftware/Brave-Browser/External Extensions/${ext.id}.json".text = config.home.file."${config.xdg.configHome}/brave/External Extensions/${ext.id}.json".text;
    })
    config.programs.brave.extensions;
in
{
  programs.brave = {
    enable = true;
    extensions = [
      { id = "mopnmbcafieddcagagdcbnhejhlodfdd"; } # polkadot-js
      { id = "lpilbniiabackdjcionkobglmddfbcjo"; } # waves keeper
      { id = "nhnkbkgjikgcigadomkphalanndcapjk"; } # clover wallet
    ];
  };

  # temporary fix wrong path
  xdg.configFile = mkMerge extFiles;
}
