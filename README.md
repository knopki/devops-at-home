# devops@home

NixOS yeeeeaaaahhhh!

## How to create a NixOS installation media

Build ISO:

```sh
nix build .#nixosConfigurations.iso-desktop.config.system.build.isoImage
```

Copy it to the USB drive from `result/iso` via `dd` or `usbimager`.

## How to install NixOS

Boot the NixOS installer ISO. Check that you can connect to the machine via SSH.

Get a machine's public AGE key from the host SSH keys:

```sh
nix-shell -p ssh-to-age --run 'ssh-keyscan x.x.x.x | ssh-to-age'
```

Save this key to the `.sops.yaml`. setup `secrets/<hostname>.yaml` with all needed secrets.

Run something like this:

```sh
nixos-anywhere -f .#name --copy-host-keys \
  --disk-encryption-keys /tmp/disk.key /tmp/deploy/disk.key \
  --target-host root@x.x.x.x`
```

Where:

- `name` is `nixosConfiguration`'s name
- `/tmp/deploy/disk.key` contains initial LUKS password.

Login to the machine after reboot.
