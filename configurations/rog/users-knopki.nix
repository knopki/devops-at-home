{
  config,
  pkgs,
  self,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    chezmoi
    wget
    curl
  ];

  preservation.preserveAt."/state".users.knopki = {
    directories = [
      {
        directory = ".gnupg";
        mode = "0700";
      }
      {
        directory = ".local/share/keyrings";
        mode = "0700";
      }
      {
        directory = ".ssh";
        mode = "0700";
      }
      ".config/chezmoi"
      ".config/git"
      ".local/share/chezmoi"
      ".local/share/direnv"
      ".local/state/nix"
      ".local/state/nvim"
      ".mozilla"
      "prj"
    ];
    files = [
      ".face"
      ".face."
      ".curlrc"
      ".wgetrc"
    ];
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
      self.lib.ssh-pubkeys.knopki-ssh-pubkey1
    ];
    hashedPasswordFile = config.sops.secrets.knopki-user-password.path;
  };

  # Note that immediate parent directories of persisted files can also be
  # configured with ownership and permissions from the `parent` settings if
  # `configureParent = true` is set for the file.
  systemd.tmpfiles.settings.preservation = {
    "/home/knopki/.config".d = {
      user = "knopki";
      group = "knopki";
      mode = "0700";
    };
    "/home/knopki/.local".d = {
      user = "knopki";
      group = "knopki";
      mode = "0700";
    };
    "/home/knopki/.local/share".d = {
      user = "knopki";
      group = "knopki";
      mode = "0700";
    };
    "/home/knopki/.local/state".d = {
      user = "knopki";
      group = "knopki";
      mode = "0700";
    };
  };
}
