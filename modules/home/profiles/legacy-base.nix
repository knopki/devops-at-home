{
  lib,
  pkgs,
  osConfig,
  self,
  ...
}:
let
  inherit (lib) mkDefault mkIf optionals;
in
{
  home = {
    # by default, state version is machine's state version
    stateVersion = mkDefault (optionals (osConfig != null) osConfig.system.stateVersion);
  };

  nix = mkIf (osConfig == null) {
    package = mkDefault pkgs.nix;
    settings = {
      inherit (self.nixConfig) experimental-features extra-substituters extra-trusted-public-keys;
    };
  };

  programs = {
    fzf = {
      enable = lib.mkDefault true;
      defaultCommand = "${pkgs.fd}/bin/fd --type f";
      fileWidgetOptions = [ " --preview 'head {}'" ];
      changeDirWidgetCommand = "${pkgs.fd}/bin/fd --type d";
      changeDirWidgetOptions = [ "--preview 'tree -C {} | head -200'" ];
    };

    jq.enable = lib.mkDefault true;

    lesspipe.enable = lib.mkDefault true;

    readline = {
      enable = lib.mkDefault true;
      bindings = {
        # These allow you to use ctrl+left/right arrow keys to jump the cursor over words
        "\e[5C" = "forward-word";
        "\e[5D" = "backward-word";
      };
      variables = {
        # do not make noise
        bell-style = "none";
      };
    };

    ssh = {
      enable = lib.mkDefault true;
      compression = false;
      controlMaster = "auto";
      controlPersist = "2h";
      extraConfig = ''
        AddKeysToAgent yes
      '';
      matchBlocks = {
        "localhost" = {
          compression = false;
          extraOptions = {
            ControlMaster = "no";
          };
        };
        "* !localhost" = {
          extraOptions = {
            ControlMaster = "auto";
            ControlPersist = "2h";
          };
        };
        "*" = {
          serverAliveCountMax = 10;
          extraOptions = {
            TCPKeepAlive = "yes";
            PubkeyAcceptedKeyTypes = "+ssh-rsa";
            HostkeyAlgorithms = "+ssh-rsa";
          };
        };
        "*.onion" = {
          proxyCommand = "socat - SOCKS4A:localhost:%h:%p,socksport=9050";
        };
      };
      forwardAgent = true;
      serverAliveInterval = 10;
    };
  };

  # sometimes rewriten by evil forces and prevent activation
  # xdg.configFile."fontconfig/conf.d/10-hm-fonts.conf".force = true;
}
