{ ... }:
{
  home.file = {
    ".gnupg/gpg.conf".text = ''
      default-key 58A58B6FD38C6B66

      keyserver  hkp://pool.sks-keyservers.net
      use-agent
    '';
  };
}
