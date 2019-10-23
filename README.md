# DevOps@home

Configuration management of the my personal machines, my dotfiles, my other somethings. Because why not.

Target platforms: NixOS, Fedora CoreOS (legacy), Fedora Project Silverblue (legacy).

## Requirements

- `git`
- `direnv`
- `nix` (good luck if not on NixOS)
- `pass`

All other dependencies will be installed by `nix-shell`.

## How to use

Deployment is biased now: `Ansible` for legacy systems and `Morph` for NixOS.


### NixOS

You can build like:

```shell
morph build nix/deploy.nix --on="*alien*"
```

You can build, deploy and activate like:

```shell
morph deploy nix/deploy.nix --on="*panzer*" switch
```

#### Update dependencies

```shell
niv update <package_in_sources_json>
```

#### Manual apply

If something goes wrong or for development.

Copy configuration from the `nix` folder to the target machine.

Apply target configuration:

```shell
sudo nixos-rebuild switch -I "nixos-config=$PWD/nix/config/alien.1984.run.nix"
```
### Ansible

You can deploy to the non-NixOS machines with something like:

```shell
cd ansible
ansible-playbook playbooks/main.yml
```

Actually, almost all configuration removed (nix ftw), used only to deploy secrets.
