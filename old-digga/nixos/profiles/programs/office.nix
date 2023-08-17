{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    anytype
    aspellDicts.en
    aspellDicts.ru
    gnome.simple-scan
    isync
    ocrfeeder
    ocrmypdf
    offlineimap
    pdfarranger
    qpdf
    rclone
    speedcrunch
    zotero
  ];
}
