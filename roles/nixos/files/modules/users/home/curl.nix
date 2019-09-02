{ config, lib, pkgs, user, ... }:
with lib; {
  options.local.curl.enable = mkEnableOption "curl configuration";

  config = mkIf config.local.curl.enable {
    home.packages = with pkgs; [ curl ];

    home.file = {
      ".curlrc".text = ''
        # Create the necessary local directory hierarchy as needed.
        create-dirs

        # Support gzip responses.
        compressed

        # FTP setup.
        ftp-create-dirs
        ftp-ssl
        ftp-pasv
        ftp-method = nocwd

        # Limit the time (in seconds) the connection to the server is allowed to take.
        connect-timeout = 30

        # Follow HTTP redirects.
        location

        # Display transfer progress as a progress bar.
        progress-bar
      '';
    };
  };
}
