{ config, self, ... }:
{
  home-manager.users.knopki =
    { ... }:
    {
      imports = with self.modules.homeManager; [ profiles-knopki-at-rog ];
    };

  sops.secrets = {
    knopki-user-password.neededForUsers = true;
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
      ".local/state/nvim"
      ".local/share/direnv"
      ".local/state/nix"
      ".mozilla"
    ];
    files = [ ];
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
