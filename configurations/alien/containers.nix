{ ... }:
{
  virtualisation.oci-containers.containers = {
    # how to configure:
    #   podman run --rm -it \
    #     -v /var/lib/isponsorblocktv:/app/data \
    #     ghcr.io/dmunozv04/isponsorblocktv:v2.2.1 --setup
    isponsorblocktv = {
      image = "ghcr.io/dmunozv04/isponsorblocktv:v2.2.1";
      volumes = [ "/var/lib/isponsorblocktv:/app/data" ];
    };
  };
}
