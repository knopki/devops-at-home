{ ... }:
{
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    extraConfig = ''
      allow-loopback-pinentry
    '';
    defaultCacheTtl = 86400;
    defaultCacheTtlSsh = 86400;
    maxCacheTtl = 2592000;
    maxCacheTtlSsh = 2592000;
    verbose = true;
  };
}
