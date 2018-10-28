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
