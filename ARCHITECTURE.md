# Architecture

## Overview

This is a modular NixOS configuration management system built using Nix flakes. The project follows a structured approach to manage multiple machines with shared and host-specific configurations.

## Project Structure

```
devops-at-home/
├── configurations/                 # Host-specific configurations (see README)
│   ├── dev-vm/                     # Development VM configuration
│   ├── iso-headless/               # Installation ISO configuration
│   ├── <host>/                     # Host specific configuration
│   ├── disko-configurations.nix    # Index of disco configurations
│   └── nixos-configurations.nix    # Index of NixOS configurations
├── lib/                            # Helper functions and flake modules
│   └── flake-modules/              # flake-parts-specific modules
├── modules/                        # Reusable NixOS modules
│   ├── nixos/                      # NixOS-specific modules
│   │   ├── hardware/               # Hardware-related
│   │   ├── mixins/                 # Small parts to be reused in profiles
│   │   ├── profiles/               # Big profiles (roles)
│   │   ├── programs/               # Program-specific modules
│   │   ├── services/               # Modules for services
│   │   ├── themes/                 # Look & feel modules
│   │   └── nixos-modules.nix       # Index
│   ├── home/                       # Home Manager modules (deprecated)
│   │   └── home-modules.nix        # Index
│   └── shared/                     # Shared modules
│       └── shared-modules.nix      # Index
├── overlays/                       # Package overlays
│   └── overlays.nix                # Index
├── pkgs/                           # Custom packages
│   └── <pkg name>/package.nix      # Main package file
├── secrets/                        # SOPS-encrypted secrets
│   └── <host>.yaml                 # Per-host secrets (but sometimes shared)
├── shells/                         # Development environments
│   ├── <shell name>                # Environment root
│   │   └── shell.nix/devshell.nix  # Main shell file
│   ├── numtide-debshells.nix       # Index of Numtide-based shells
│   └── shells.nix                  # Index of normal shells
├── .sops.yaml                      # SOPS secrets configuration (keys and rules)
└── flake.nix                       # Main entrypoint
```

## Design Principles

### Modularity

- **Host Configurations**: Each machine has its own configuration directory
- **Reusable Modules**: Common functionality extracted into modules
- **Profile System**: Layered profiles (common → server/workstation → devhost)

### Reproducibility

- **Flake-based**: All inputs pinned with lock file
- **Immutable Infrastructure**: Declarative configuration management
- **Version Control**: All configuration tracked in Git

### Security

- **Secrets Management**: SOPS for encrypted secrets with age keys
- **Minimal Attack Surface**: Only required services enabled
- **Secure Defaults**: Security-focused module configurations

## Core Components

### Configuration Layers

1. **Common Profile** (`modules/nixos/profiles/common.nix`)

   - Base system configuration
   - Network, Nix, SSH, and security defaults
   - Applied to all systems

1. **Specialized Profiles**

   - **Server Profile**: Headless systems, minimal packages
   - **Workstation Profile**: Desktop systems, GUI applications
   - **DevHost Profile**: Development-focused configuration

1. **Host-Specific Configuration**

   - Hardware-specific settings
   - Storage configuration (ZFS, LUKS)
   - Network and service configuration

### Module System

**Mixins** (`modules/nixos/mixins/`):

- Small, focused modules for specific functionality
- Examples: `mixin-nix.nix`, `mixin-openssh.nix`, `mixin-pipewire.nix`

**Programs** (`modules/nixos/programs/`):

- Application-specific configurations
- Example: `programs-helix.nix` with language server support

**Services** (`modules/nixos/services/`):

- Service-specific configurations
- Example: `service-kopia.nix` with backups configuration

### Package Management

**Overlays** (`overlays/`):

- Unstable package backports
- Custom package modifications
- Package version pinning

**Custom Packages** (`pkgs/`):

- Project-specific packages
- Packages not available in nixpkgs
- Automated update scripts

## Development Environments

### Shell System (`shells/`)

- **Project-specific environments**: Isolated development setups
- **Service orchestration**: Integrated database and service management
- **Tool provisioning**: Automated tool and dependency setup

### Examples

- **nixos**: NixOS development and system management

## Secrets Management

### SOPS Integration

- **Age encryption**: Modern, secure encryption
- **Per-host keys**: Separate encryption keys for each machine
- **Git-safe**: Encrypted secrets safely stored in version control

### Key Management

- **Host keys derived from SSH keys**: Automatic key generation
- **User keys**: Separate keys for user-specific secrets
- **Key rotation**: Documented process for key updates

## Network Architecture

### Firewall Configuration

- **Default deny**: Restrictive firewall rules
- **Service-specific ports**: Only required ports opened
- **Interface-based rules**: Different rules for different network interfaces

## Deployment Strategy

### Installation Process

1. **ISO Creation**: Custom installation media with SSH access
1. **Remote Installation**: `nixos-anywhere` for automated deployment
1. **Secret Provisioning**: Secure secret deployment during installation
1. **System Activation**: Automated system configuration and activation

### Update Process

1. **Flake Updates**: `nix flake update` for dependency updates
1. **System Rebuild**: `nixos-rebuild switch --flake .#hostname`
1. **Testing**: VM-based testing before deployment
1. **Rollback**: Built-in rollback capabilities

## Security Model

### System Hardening

- **Kernel parameters**: Security-focused kernel configuration
- **Service isolation**: Systemd security features
- **User permissions**: Minimal privilege principles

### Access Control

- **SSH key-based authentication**: No password authentication
- **Sudo configuration**: Wheel group restrictions
- **File permissions**: Proper secret file permissions

### Monitoring

- **System logs**: Centralized logging configuration
- **Security events**: Automated security monitoring
- **Resource monitoring**: System resource tracking
