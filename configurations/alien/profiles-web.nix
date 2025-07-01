{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.firefox-with-keepassxc
  ];

  programs.brave = {
    enable = true;
    extensions = [
      # "jhnleheckmknfcgijgkadoemagpecfol" # auto tab discard
    ];
  };
}
