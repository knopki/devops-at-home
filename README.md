# devops@home

NixOS yeeeeaaaahhhh!

## How to create a NixOS installation media

Build ISO:

```sh
nix build .#nixosConfigurations.iso-desktop.config.system.build.isoImage
```

Copy it to the USB drive from `result/iso` via `dd` or `usbimager`.
