{ ... }:
{
  virtualisation.oci-containers.containers = {
    # how to configure:
    #   podman run --rm -it \
    #     -v /var/lib/isponsorblocktv:/app/data \
    #     ghcr.io/dmunozv04/isponsorblocktv:v2.6.0 --setup
    isponsorblocktv = {
      image = "ghcr.io/dmunozv04/isponsorblocktv:v2.6.0";
      volumes = [ "/var/lib/isponsorblocktv:/app/data" ];
    };
  };
}
