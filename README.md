# DevOps@home

Configuration management of my personal machines, my dotfiles, my other somethings. Because why not.

Target platforms: Fedora CoreOS, Fedora Project Silverblue, OpenWrt.
Set-up method: incredibly over-engineered Ansible orchestration.

## Features

* Encrypted versioning of files with sensitive content in separate `passwordstore` repo.

### Infrastructure

* Full OpenWrt router configuration from `ansible` values
* yum repositories setup
* rpm-ostree rebase/upgrade/package installation
* Users and groups management
* Authorized ssh keys
* sshd configuration
* locale configuration
* timezone configuration
* hostname configuration
* sysctl configuration
* chrony configuration
* lvm.conf
* firewalld
* sudo/polkit configuration
* wireguard and openvpn tunnels
* DigitalOcean agent
* Telegram proxy
* Cjdns mesh and overlay network on every machine
* Installation of binary executables, that not in OS' repositories
* Installation of fonts
* Install flatpak remotes and packages
* Tuned profiles
* thermald
* `lm-sensors`
* `fancontrol` configuration
* gdm
* modprobe
* `pip` package installation
* vconsole
* Alienware 15 R2 sound fix

### Dotfiles

* `environment.d` variables set
* shell environment (`zsh`, `tmux`, `git`, `ssh`, `vim`, etc)
* `sway` environment with `mako`, `py3status`, `rofi`, etc
* `termite`
* `qt5ct`
* CACHEDIR.TAG files
* VS Code

## Prerequirements

* `git`
* `ansible` ^2.6
* `pass`/`gopass`

## Installation

```bash
$ git clone git@github.com:/knopki/password-store ~/.password-store
$ git clone git@github.com:/knopki/devops-at-home ~/dev/knopki/devops-at-home
$ cd ~/dev/knopki/devops-at-home/ansible
$ ansible-playbook playbooks/main.yml [ -l some_hosts ] [ -t some_tags ]
```

# Nix Stuff

Testing `nix` and `NixOS` now. Some configuration created.

## How to install `nix` on non-nix OS

Install [PRoot](https://github.com/proot-me/PRoot).

Update `~/.config/nix/nix.conf`:

```ini
sandbox = false
```

Install:
```shell
# proot -b /var/home/sk/.nix:/nix zsh
$ . ~/.nix-profile/etc/profile.d/nix.sh
$ curl https://nixos.org/nix/install | sh
```
If latest version doesn't install, then try some previos (edit install script).

## How to deploy `nix` configuration

To apply to all hosts (change `all` to target hostname if you want) run `nix-build`.
Then apply compiled closure by runnig `./result`. Like this:

```shell
# nix-build -A all && ./result`
```
