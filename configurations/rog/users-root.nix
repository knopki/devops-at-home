{
  self,
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    chezmoi
    wget
    curl
  ];

  preservation.preserveAt."/state".users.root = {
    # specify user home when it is not `/home/${user}`
    home = "/root";
    directories = [
      {
        directory = ".ssh";
        mode = "0700";
      }
      ".config/chezmoi"
      ".config/git"
      ".config/helix"
      ".local/share/chezmoi"
      ".local/state/nix"
    ];
    files = [
      ".curlrc"
      ".wgetrc"
    ];
  };

  sops.secrets = {
    root-user-password.neededForUsers = true;
    root-chezmoi-age-key = { };
  };

  # Note that immediate parent directories of persisted files can also be
  # configured with ownership and permissions from the `parent` settings if
  # `configureParent = true` is set for the file.
  systemd.tmpfiles.settings.preservation = {
    "/root/.config".d = {
      user = "root";
      group = "root";
      mode = "0700";
    };
    "/root/.local".d = {
      user = "root";
      group = "root";
      mode = "0700";
    };
    "/root/.local/share".d = {
      user = "root";
      group = "root";
      mode = "0700";
    };
    "/root/.local/state".d = {
      user = "root";
      group = "root";
      mode = "0700";
    };
  };

  users.users.root = {
    hashedPasswordFile = config.sops.secrets.root-user-password.path;
    openssh.authorizedKeys.keys = [
      self.lib.sshPubKeys.knopkiSshPubKey1
    ];
  };
}
