# Development Environments

## Overview

This project provides multiple development environments through Nix development
shells. Each environment is tailored for specific projects and workflows,
providing isolated dependencies and tools.

## Shells

Every shell is defined in a separate subdirectory within the `/shells`
directory.
Each shell module is added to the list in a file corresponding to its type.

### Types of Shells

**Numtide DevShells** (`numtide-devshells.nix`):
- Feature-rich development environments
- Service orchestration support
- Environment variable management
- Command aliases and shortcuts

**Standard Nix Shells** (`shells.nix`):
- Simple `mkShell` environments
- Basic package provisioning
- Legacy shell support


## Available Environments

- [Github Actions](gh-actions) - Github Actions development
- [nixos](nixos/README.md) - NixOS system development and administration
- [ODOO 11 Doodba](odoo-doodba-11/README.md) - ERP development with Doodba framework
- [Infrastructure Management](wrk-a25-infra/README.md) - Cloud infrastructure management (terraform)

## Development Workflow

### Shell Activation

**Method 1: Direct Access**
```bash
cd project-directory
nix develop "<path to the this project's root>#<shell-name>"
```

**Method 2: direnv Integration**
```bash
cd project-directory
echo "use flake <path to the this project's root>#<shell-name>" > .envrc
direnv allow
```

## Custom Scripts and Tools

### update-packages

**Purpose**: Update custom packages in the flake
**Location**: `/pkgs/update-packages/package.nix`

**Usage**:
```bash
update-packages --all                       # Update all packages
update-packages package-name                # Update specific package
update-packages --all --argstr commit true  # Auto-commit updates
```

## Best Practices

### Secret Management

1. **Never commit secrets to shells**
2. **Use environment files for local secrets**
3. **Reference secrets through SOPS/secret service when possible**
