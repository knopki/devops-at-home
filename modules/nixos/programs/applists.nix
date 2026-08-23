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
    devAi = mkEnableOption "Install set of AI dev applications";
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
        cifs-utils
        nftables
        tealdeer
        witr
        google-cloud-sdk
      ]
      ++
        optionals
          (cfg.admin && (config.virtualisation.docker.enable || config.virtualisation.podman.enable))
          [
            lazydocker
          ]
      ++ optionals cfg.adminGUI [
        # anydesk
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
        herdr
      ]
      ++ optionals cfg.dev [
        android-tools
        binutils
        devenv
        gcc
        gh
        difftastic
        gnupg
        imgcat
        jq
        just
        lazygit
        lima
        mise
        nono
        python3
        rclone
        unixtools.xxd
        worktrunk
        surge-cli
        arduino-ide
        arduino-cli
      ]
      ++ optionals cfg.devAi [
        opencode
        agent-browser # required by some agents and more
        chromium # for agent-browser
        tuicr
        # ai stuff deps
        fd
        ripgrep
        uv # required by hermes + skills
        nodejs # required by hermes + skills (npx)
        bun # required by skills
        skills
        # libopus?
        ffmpeg
        # espeak?
        # wl-clipboard?
        # portaudio # required by hermes?
        tirith # required by hermes
        openspec
        opencv # required by skills
        # ffmpeg # required by skills
        # ocrmypdf
        pandoc # required by skills
        surge-cli # required by skills
        codegraph # required by coding agents
        pi-coding-agent
        dsh
      ]
      ++ optionals cfg.devAi (
        with python3Packages;
        [
          # standard set of packages for AI
          cryptography
          h5py
          lxml
          matplotlib
          markitdown
          numpy
          openpyxl
          pandas
          pytz
          pymupdf
          python-docx
          pytesseract
          pyfiglet
          scipy
          sklearn-compat
          seaborn
          requests
          reportlab
          sympy
        ]
      )
      ++
        optionals (cfg.dev && (config.virtualisation.docker.enable || config.virtualisation.podman.enable))
          [
            distrobox
            dive
            docker-compose
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
        exiftool
        fclones
        fclones-gui
        findimagedupes
        gallery-dl
        imagemagick
        picard
        pinta
        rnr
        mpv-with-plugins
        swayimg
        streamrip
        szyszka
        # upscaler # temporary disable - not used
        qbittorrent
        yt-dlp
      ]
      ++ optionals cfg.office [
        # aliza # temprorary disabled - not used
        anytype
        brave
        # citations # temporary disabled - not used
        gImageReader
        img2pdf
        keepassxc
        khal
        khard
        libsecret
        naps2
        nextcloud-client
        obsidian
        ocrmypdf
        onlyoffice-desktopeditors
        pdfarranger
        poppler-utils
        taskwarrior3
        taskwarrior-tui
        tasksh
        telegram-desktop
        timewarrior
        qalculate-gtk
        qpdf
        vdirsyncer
        weasis
        zotero
      ]
    );

    programs = {
      git.enable = mkDefault (cfg.admin || cfg.cliTools || cfg.dev);

      mtr.enable = mkDefault cfg.networking;

      thunderbird.enable = mkDefault cfg.office;
    };
  };
}
