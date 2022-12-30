{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    firefox
  ];

  programs.brave = {
    enable = true;
    extensions = [
      "jhnleheckmknfcgijgkadoemagpecfol" # auto tab discard
    ];
  };
}
