# Sudo

[![Ansible Galaxy][galaxy_image]][galaxy_link]
[![Build Status][travis_image]][travis_link]
[![Latest tag][tag_image]][tag_url]
[![Gitter chat][gitter_image]][gitter_url]

A role for managing sudo.

This role uses sudoers.d to manage the sudo capabilities of your users. Each
user gets its own sudoers.d file. This means the role can be used from multiple
roles to add and manage new users without interfering with the other
users/roles.

The defaults and aliases however can only be managed from one location and
should not be specified if you add this role as a dependency to your own role.

Following roles where designed to neatly work together with this role:

- [user][grog.user], for managing users.
- [authorized-key][grog.authorized-key], for managing authorized-keys.

The [management-user][grog.management-user] role combines all these roles in
one easy to use role.

## Requirements

- Hosts should be bootstrapped for ansible usage (have python,...)
- Root privileges, eg `become: yes`

## Role Variables

| Variable | Description | Default value |
|----------|-------------|---------------|
| `sudo_package` | Install sudo if not available | `yes` |
| `sudo_list` | List of users and their sudo settings **(see details!)** | `[]` |
| `sudo_list_host`| List of users and their sudo settings **(see details!)**  | `[]` |
| `sudo_list_group` | List of users and their sudo settings **(see details!)** | `[]` |
| `sudo_default_sudoers` | Restore default sudoers file if altered? | `no` |
| `sudo_default_sudoers_src_path` | Path (local) to default sudoers file | path to included default file |
| `sudo_defaults` | List of defaults | `[]` |
| `sudo_host_aliases` | List of host aliases **(see details!)** | `[]` |
| `sudo_user_aliases` | List of user aliases **(see details!)** | `[]` |
| `sudo_runas_aliases` | List of run as aliases **(see details!)** | `[]` |
| `sudo_cmnd_aliases` | List of command aliases **(see details!)** | `[]` |
| `sudo_sudoersd_dir` | Sudoersd directory | '/etc/sudoers.d' |

#### `sudo_list` details

`sudo_list`, `sudo_list_host` and `sudo_list_group` are merged when managing
the sudo settings. You can use the host and group lists to specify users
settings per host or group off hosts.

The sudo list allows you to define which users sudo settings must be managed.
Each item in the list can have following attributes:

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `hosts` | Hosts | yes | / |
| `as` | Operators | yes | / |
| `commands` | Commands | yes | / |
| `nopasswd` | NOPASSWD flag | no | `no` |
| `passwd` | PASSWD flag | no | `no` |
| `noexec` | NOEXEC flag | no | `no` |
| `exec` | EXEC flag | no | `no` |
| `nosetenv` | NOSETENV flag | no | `no` |
| `setenv` | SETENV flag | no | `no` |
| `nologinput` | NOLOG_INPUT flag | no | `no` |
| `loginput` | LOG_INPUT flag | no | `no` |
| `nologoutput` | NOLOG_OUTPUT flag | no | `no` |
| `logoutput` | LOG_OUTPUT flag | no | `no` |

You can provide these attrubutes in a list if a user needs multiple entries.

###### Example `sudo_list`

```yaml
sudo_list:
  - name: root
    sudo:
      hosts: ALL
      as: ALL:ALL
      commands: ALL
  - name: user1
  - name: user2
    sudo:
      hosts: ALL
      as: ALL
      commands: ALL
      nopasswd: yes
  - name: user3
    sudo:
      - hosts: ALL
        as: root
        commands: /usr/sbin/poweroff
        nopasswd: yes
      - hosts: ALL
        as: ALL
        commands: /usr/sbin/less
        noexec: yes
```

#### `sudo_***_aliases` details

The aliases lists allow you to specify multiple aliases. Each item in the
list has a name and an alias.

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `name` | Name of the alias | yes | / |
| `alias` | Alias | yes | / |

###### Example `sudo_***_aliases`

```yaml
sudo_***_aliases:
  - name: EXAMPLE1
    alias: 'shutdown'
  - name: EXPAMPLE2
    alias: 'test, test1, test2'
```

## Dependencies
- [GROG.package][grog.package]

## Example Playbook

```yaml
---
- hosts: servers
  roles:
  - { role: GROG.sudo, become: yes }
```

Inside `group_vars/servers.yml`:

```yaml
sudo_list_group:
  - name: user
    sudo:
      hosts: ALL
      as: ALL
      commands: ALL
```

## Contributing
All assistance, changes or ideas [welcome][issues]!

## Author
By [G. Roggemans][groggemans]

## License
MIT

[galaxy_image]:         http://img.shields.io/badge/galaxy-GROG.sudo-660198.svg?style=flat
[galaxy_link]:          https://galaxy.ansible.com/GROG/sudo
[travis_image]:         https://travis-ci.org/GROG/ansible-role-sudo.svg?branch=master
[travis_link]:          https://travis-ci.org/GROG/ansible-role-sudo
[tag_image]:            https://img.shields.io/github/tag/GROG/ansible-role-sudo.svg
[tag_url]:              https://github.com/GROG/ansible-role-sudo/tags
[gitter_image]:         https://badges.gitter.im/GROG/chat.svg
[gitter_url]:           https://gitter.im/GROG/chat

[grog.user]:            https://galaxy.ansible.com/GROG/user
[grog.authorized-key]:  https://galaxy.ansible.com/GROG/authorized-key
[grog.management-user]: https://galaxy.ansible.com/GROG/management-user
[grog.package]:         https://galaxy.ansible.com/GROG/package

[issues]:               https://github.com/GROG/ansible-role-sudo/issues
[groggemans]:           https://github.com/groggemans
