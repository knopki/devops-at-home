{ config, lib, ... }:
{
  imports = [ ../profiles/programs/brave.nix ];

  programs.brave = {
    extensions = [
      { id = "mopnmbcafieddcagagdcbnhejhlodfdd"; } # polkadot-js
      { id = "lpilbniiabackdjcionkobglmddfbcjo"; } # waves keeper
      { id = "nhnkbkgjikgcigadomkphalanndcapjk"; } # clover wallet
    ];
  };
}
