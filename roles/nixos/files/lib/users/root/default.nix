{ config, pkgs, lib, username, ... }:
with builtins; {
  hm = lib.mkMerge (lib.reverseList [
    # common
    (import ../fish.nix { inherit config pkgs lib username; })
    (import ../fzf.nix { })
    (import ../git.nix { })
    (import ../gpg-agent.nix { })
    (import ../profile.nix { inherit config username; })
    (import ../readline.nix { })
    (import ../ssh.nix { })
    (import ../xdg.nix { })
    (import ../zsh.nix { inherit config pkgs lib username; })
    # specific
    (import ./env.nix { inherit config pkgs lib; })
    (import ./fish.nix { inherit config pkgs lib username; })
    {
      home.language.monetary = "ru_RU.UTF-8";
      home.language.time = "ru_RU.UTF-8";
      home.stateVersion = "18.09";
      programs.git = {
        userEmail = "root@localhost";
        userName = "Root";
      };
    }
  ]);

  systemUser = {
    hashedPassword = readFile "/etc/nixos/secrets/root_password";
    openssh.authorizedKeys.keyFiles = [ "/etc/nixos/secrets/sk_id_rsa.pub" ];
    shell = pkgs.fish;
  };
}
