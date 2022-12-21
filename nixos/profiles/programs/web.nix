{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    firefox
    tor-browser-bundle-bin
  ];

  programs.brave = {
    enable = true;
    extensions = [
      "jhnleheckmknfcgijgkadoemagpecfol" # auto tab discard
    ];
  };
}
