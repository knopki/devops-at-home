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
