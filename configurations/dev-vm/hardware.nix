{ inputs, ... }:
{
  imports = [ inputs.microvm.nixosModules.microvm ];

  microvm = {
    hypervisor = "qemu";
    vcpu = 1;
    mem = 1024;
    interfaces = [
      {
        type = "tap";
        id = "dev-vm";
        mac = "02:00:00:00:00:01";
      }
    ];
    shares = [
      {
        tag = "ro-store";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
      }
      {
        proto = "9p";
        tag = "home";
        # Source path can be absolute or relative
        # to /var/lib/microvms/$hostName
        source = "home";
        mountPoint = "/home";
      }
    ];
  };
}
