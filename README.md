# devops@home

Personal NixOS configuration management system using Nix flakes for multiple
machines with modular architecture, encrypted secrets, and reproducible
development environments.

Home Manager is not used for managing dotfiles in this repository. Dotfiles are
managed by `chezmoi` in a
[separate repository](https://github.com/knopki/dotfiles).

This project uses [devenv.sh](https://devenv.sh) to create a reproducible
development environment. See also
[knopki/devenvs](https://github.com/knopki/devenvs) - a collection of
`devenv.sh` modules.

## Overview

This repository contains a NixOS configuration system that manages:

- **Multiple Hosts**: Laptops and installation media
- **Modular Architecture**: Reusable modules, roles, profiles, and mixins
- **Secrets Management**: SOPS with age encryption for secure configuration
- **Storage Systems**: ZFS and Btrfs with encryption and snapshots
- **Container Support**: Podman with development containers

## Documentation

- **[Usage Guide](USAGE.md)**: Recipes and tips for use
- **[Architecture](ARCHITECTURE.md)**: System design and structure
- **[Host Configurations](configurations/README.md)**: Detailed host
  specifications
- **[AGENTS.md](AGENTS.md)**: Instructions for AI agents

## License

MIT License - see [LICENSE](LICENSE) for details.
