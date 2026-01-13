{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib.lists) optionals;
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption;
  inherit (lib) lowPrio;
  cfg = config.custom.applists;
in
{
  options.custom.applists = {
    enable = mkEnableOption "Enable application lists profile";
    admin = mkEnableOption "Install set of admin applications";
    adminGUI = mkEnableOption "Install set of admin applications";
    cliTools = mkEnableOption "Install set of optional but nice command line applications";
    edu = mkEnableOption "Install set of education applications";
    dev = mkEnableOption "Install set of dev applications";
    hardware = mkEnableOption "Install set of hardware applications";
    networking = mkEnableOption "Install set of networking applications";
    media = mkEnableOption "Install set of media applications";
    office = mkEnableOption "Install set of office applications";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = map lowPrio (
      with pkgs;
      [
        findutils
      ]
      ++ optionals cfg.admin [
        # gnupg
      ]
      ++
        optionals
          (cfg.admin && (config.virtualisation.docker.enable || config.virtualisation.podman.enable))
          [
            lazydocker
          ]
      ++ optionals cfg.adminGUI [
        anydesk
        remmina
      ]
      ++ optionals cfg.cliTools [
        chezmoi
        fd
        file
        dust
        edir
        jq
        libarchive
        lsof
        pstree
        ranger
        rclone
        rnr
        ripgrep
        sysstat
        tmux
        trashy
        tree
      ]
      ++ optionals cfg.dev [
        binutils
        devenv
        gh
        gnupg
        imgcat
        jq
        just
        lazygit
        lima
        python3
        rclone
      ]
      ++
        optionals (cfg.dev && (config.virtualisation.docker.enable || config.virtualisation.podman.enable))
          [
            distrobox
            dive
          ]
      ++ optionals cfg.edu [
        anki
        obsidian
      ]
      ++ optionals cfg.hardware [
        acpi
        dosfstools
        gptfdisk
        hdparm
        nvme-cli
        lm_sensors
        pciutils
        powertop
        smartmontools
        usbutils
        wirelesstools
      ]
      ++ optionals cfg.networking [
        curl
        dnsutils
        iputils
        ngrep
        nmap
        tcpdump
        rclone
        rsync
        wget
      ]
      ++ optionals cfg.media [
        asciinema
        czkawka-full
        edir
        fclones
        fclones-gui
        findimagedupes
        gallery-dl
        handbrake
        imagemagick
        picard
        pinta
        rnr
        mpv-with-plugins
        swayimg
        streamrip
        szyszka
        upscaler
        qbittorrent
        yt-dlp
      ]
      ++ optionals cfg.office [
        aliza
        anytype
        citations
        dialect
        gImageReader
        img2pdf
        keepassxc
        khal
        khard
        naps2
        nextcloud-client
        obsidian
        ocrmypdf
        onlyoffice-desktopeditors
        pdfarranger
        poppler-utils
        telegram-desktop
        qalculate-gtk
        qpdf
        vdirsyncer
        weasis
        zotero
      ]
    );

    programs.git.enable = mkDefault (cfg.admin || cfg.cliTools || cfg.dev);

    programs.mtr.enable = mkDefault cfg.networking;

    programs.thunderbird.enable = mkDefault cfg.office;
  };
}
