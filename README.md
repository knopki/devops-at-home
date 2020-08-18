# devops@home

Configuration management of the my personal machines, my dotfiles,
my other somethings. Because why not.

## Setup

Requirements:

- `nix` (`pkgs.nixFlakes`)
- `direnv` && `nix-direnv`

`direnv allow` and everything is ready.

## Usage

Check configuration:

```sh
nix flake check
```

Switch to configuration:

```sh
nixos-rebuild switch --flake .#hostname
```

Build an ISO:

```sh
nix build -v .#nixosConfigurations.iso.config.system.build.isoImage
```

Open shell with package:

```sh
nix shell .#packages.x86_64-linux.winbox
```

### Show Me What You Got

```
├───checks
│   └───x86_64-linux
│       ├───alien: derivation 'nixos-system-alien-20.03.20200816.f8a10a7'
│       ├───doom-emacs: derivation 'emacs-with-packages-26.3'
│       ├───winbox: derivation 'winbox-bin-3.20'
│       └───winbox-bin: derivation 'winbox-bin-3.20'
├───devShell
│   ├───aarch64-linux: development environment 'nix-shell'
│   ├───i686-linux: development environment 'nix-shell'
│   ├───x86_64-darwin: development environment 'nix-shell'
│   └───x86_64-linux: development environment 'nix-shell'
├───nixosConfigurations
│   ├───alien: NixOS configuration
│   └───iso: NixOS configuration
├───nixosModules
│   ├───azire-vpn: NixOS module
│   ├───boot: NixOS module
│   ├───cachix: NixOS module
│   ├───home-manager: NixOS module
│   ├───meta: NixOS module
│   └───profiles: NixOS module
├───overlay: Nixpkgs overlay
├───overlays: unknown
└───packages
    ├───aarch64-linux
    │   └───doom-emacs: package 'emacs-with-packages-26.3'
    ├───i686-linux
    │   ├───doom-emacs: package 'emacs-with-packages-26.3'
    │   ├───winbox: package 'winbox-bin-3.20'
    │   └───winbox-bin: package 'winbox-bin-3.20'
    ├───x86_64-darwin
    │   └───doom-emacs: package 'emacs-with-packages-26.3'
    └───x86_64-linux
        ├───doom-emacs: package 'emacs-with-packages-26.3'
        ├───winbox: package 'winbox-bin-3.20'
        └───winbox-bin: package 'winbox-bin-3.20'
```
