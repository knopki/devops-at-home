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

Update inputs:

``` sh
nix flake update --update-input nixpkgs
```

Special case for updating Doom Emacs:

``` sh
nix flake update --update-input nix-doom-emacs
hm-modules/emacs/update.py
git add hm-modules/emacs/pinned.json
```

### Show Me What You Got

```
├───checks
│   └───x86_64-linux
│       ├───alien: derivation 'nixos-system-alien-20.09.20201114.29e9c10'
│       ├───sway-scripts: derivation 'sway-scripts'
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
│   ├───profiles: NixOS module
│   └───users: NixOS module
├───overlay: Nixpkgs overlay
├───overlays: unknown
└───packages
    ├───aarch64-linux
    │   └───sway-scripts: package 'sway-scripts'
    ├───i686-linux
    │   ├───sway-scripts: package 'sway-scripts'
    │   ├───winbox: package 'winbox-bin-3.20'
    │   └───winbox-bin: package 'winbox-bin-3.20'
    ├───x86_64-darwin
    │   └───sway-scripts: package 'sway-scripts'
    └───x86_64-linux
        ├───sway-scripts: package 'sway-scripts'
        ├───winbox: package 'winbox-bin-3.20'
        └───winbox-bin: package 'winbox-bin-3.20'
```
