# Temporary configuration that should go away
# Remove or move to modules/other files
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    iproute2
    mtr
    dig
    curl
    whois
    tcpdump
    wireshark
    termshark
    ngrep
    nmap
    netcat-openbsd
    socat
    iperf3
    iftop
    speedtest-cli
    rsync
    jq
  ];

  programs.throne = {
    enable = true;
    tunMode.enable = true;
  };
}
