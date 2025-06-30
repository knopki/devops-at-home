{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.firefox
  ];

  programs.brave = {
    enable = true;
    extensions = [
      # "jhnleheckmknfcgijgkadoemagpecfol" # auto tab discard
    ];
  };
}
