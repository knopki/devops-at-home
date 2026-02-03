{
  config,
  self,
  ...
}:
{
  custom.preservation = {
    preserveAtTemplates."/state".users.knopki = {
      auto.enable = true;
      xdgTmpfiles.enable = true;
    };
    preserveAt."/state".users.knopki = {
      directories = [
        ".android"
        ".arduino15"
        # ".cache/.bun"
        ".cache/np"
        # ".cache/opencode"
        ".config/arduino-ide"
        ".config/cachix" # devenv use
        ".config/gcloud" # devenv use
        ".config/media-viewer"
        ".config/nix-inspect" # devenv use
        ".config/opencode" # devenv use
        ".config/yandex-cloud" # devenv use
        ".config/zed" # devenv use
        {
          directory = ".lima";
          mode = "0700";
        } # devenv use
        ".local/share/calendars"
        ".local/share/contacts"
        ".local/share/media-viewer"
        ".local/share/nix"
        ".local/share/opencode" # devenv use
        ".local/share/RecentDocuments"
        ".local/share/uv" # devenv use
        ".local/share/zed" # devenv use
        # ".mozilla"
        ".terraformrc" # devenv use
        "desktop"
        "docs"
        "downloads"
        "music"
        "pics"
        "prj"
        "public"
        "remote"
        "templates"
        "trash"
        "videos"
      ];
      files = [
        ".resticignore"
      ];
    };
    preserveAtTemplates."/state/sensitive".users.knopki.secrets.enable = true;
    preserveAt."/state/sensitive".users.knopki.directories = [ "secrets" ];
  };

  sops.secrets = {
    knopki-user-password.neededForUsers = true;
    knopki-chezmoi-age-key.owner = config.users.users.knopki.name;
  };

  users.groups.knopki = { };
  users.users.knopki = {
    description = "Red Buttons";
    uid = 1000;
    group = "knopki";
    isNormalUser = true;
    extraGroups = with config.users.groups; [
      "adbusers"
      "audio"
      "dialout"
      "disk"
      "input"
      "libvirtd"
      "mlocate"
      "networkmanager"
      "plugdev"
      "podman"
      "pulse"
      "sound"
      "users"
      "video"
      "wheel"
      "wireshark"
      keys.name
    ];
    openssh.authorizedKeys.keys = [
      self.lib.sshPubKeys.knopkiSshPubKey1
    ];
    hashedPasswordFile = config.sops.secrets.knopki-user-password.path;
  };
}
