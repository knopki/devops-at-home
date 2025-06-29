{ packages, ... }:
{
  environment.systemPackages = [
    packages.firefox
  ];

  programs.brave = {
    enable = true;
    extensions = [
      # "jhnleheckmknfcgijgkadoemagpecfol" # auto tab discard
    ];
  };
}
