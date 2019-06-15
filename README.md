# DevOps@home

Configuration management of the my personal machines, my dotfiles, my other somethings. Because why not.

Target platforms: NixOS, Fedora CoreOS (legacy), Fedora Project Silverblue (legacy).
Set-up method: incredibly over-engineered Ansible orchestration.

Some legacy configuration is stored in Ansbile, but The Plan is:
- nix expressions are stored in `nixos` ansible role
- `ansible` just copy secrets and expressions to the target machine
- `ansible` execute `nixos-rebuild switch`

Not great, not terrible. And already works for my workstations.


## Prerequirements

- `git`
- `ansible` ^2.6
- `pass`/`gopass`

## Installation

```bash
$ git clone git@github.com:/knopki/password-store ~/.password-store
$ git clone git@github.com:/knopki/devops-at-home ~/dev/knopki/devops-at-home
$ cd ~/dev/knopki/devops-at-home/ansible
$ ansible-playbook playbooks/main.yml [ -l some_hosts ] [ -t some_tags ]
```
