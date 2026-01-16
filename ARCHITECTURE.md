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
│   │   ├── config/                 # Core system configurations
│   │   ├── hardware/               # Hardware-related
│   │   ├── misc/                   # Miscellaneous helper modules
│   │   ├── programs/               # Program-specific modules
│   │   ├── roles/                  # High-level system roles
│   │   ├── security/               # Security configurations
│   │   ├── services/               # Modules for services
│   │   ├── snippets/               # Reusable configuration snippets
│   │   ├── system/                 # System-level boot configurations
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

1. **Base Mixin** (`modules/nixos/misc/common-mixin.nix`)

   - Core system configuration modules
   - Imports config modules (locale, nix, zswap, etc.)
   - Programs, security, and services setup
   - Applied through all roles

1. **Roles** (`modules/nixos/roles/`)

   - **Server Role**: Headless systems, minimal packages, optimized for CLI usage
   - **Workstation Role**: Desktop systems, GUI applications, user-focused features
   - **DevHost Role**: Development-focused configuration with dev tools and environments
   - Each role imports the base mixin and adds specialized functionality

1. **Host-Specific Configuration**

   - Hardware-specific settings
   - Storage configuration (ZFS, LUKS)
   - Network and service configuration
   - Role selection and customization

### Module System

**Config** (`modules/nixos/config/`):

- Core system configuration modules
- Includes: `home-manager.nix`, `locale.nix`, `nix.nix`, `preservation.nix`, `zswap.nix`

**Roles** (`modules/nixos/roles/`):

- High-level system profiles defining machine types
- `server.nix` - Headless systems, minimal packages
- `workstation.nix` - Desktop systems, GUI applications
- `devhost.nix` - Development-focused configuration

**Services** (`modules/nixos/services/`):

- Service-specific configurations
- Includes: `cosmic-de.nix`, `networking.nix`, `openssh.nix`, `pipewire.nix`

**System** (`modules/nixos/system/`):

- System-level boot and kernel configurations
- Includes: `lanzaboote.nix` (Secure Boot), `systemd-boot.nix`

**Security** (`modules/nixos/security/`):

- Security-related configurations
- Example: `sudo.nix`

**Programs** (`modules/nixos/programs/`):

- Application-specific configurations
- Includes: `applists.nix`, `helix.nix` (with language server support), `htop.nix`, `ssh-well-known-hosts.nix`

**Misc** (`modules/nixos/misc/`):

- Miscellaneous helper modules
- Includes: `common-mixin.nix`, `no-docs.nix`

### Package Management

**Overlays** (`overlays/`):

- Unstable package backports
- Custom package modifications
- Package version pinning

**Custom Packages** (`pkgs/`):

- Project-specific packages
- Packages not available in nixpkgs
- Automated update scripts

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
