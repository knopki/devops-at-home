# Management user

[![Ansible Galaxy][galaxy_image]][galaxy_link]
[![Build Status][travis_image]][travis_link]
[![Latest tag][tag_image]][tag_url]
[![Gitter chat][gitter_image]][gitter_url]


A role for managing a management user.

## Requirements

- Hosts should be bootstrapped for ansible usage (have python,...)
- Root privileges, eg `become: yes`
- `useradd`, `userdel` and `usermod` should be available on the host
- sudo should be available **(attention: this role will enable sudoers.d if not
  enabled)**

## Role Variables

| Variable | Description | Default value |
|----------|-------------|---------------|
| `management_user_list` | List of management users | `[ management_user_settings ]` |
| `management_user_list_host` | List of management users | `[]` |
| `management_user_list_group` | List of management users | `[]` |
| `management_user_settings` | Default Settings for the management user **(see details!)** | see details |
| `management_user_key` | SSH key for the default user settings | `~/.ssh/id_rsa.pub` |

`management_user_list`, `_list_host` and `_list_group` are merged when managing the
users. You can use the host and group lists to specify users per host or group
off hosts.

#### `management_user_settings` details

By default a user with following data will be created;

```yaml
management_user_key: "{{ lookup('file', '~/.ssh/id_rsa.pub') }}"

management_user_settings:
  name: management
  comment: Ansible
  shell: '/bin/bash'
  authorized_keys:
    - key: "{{ management_user_key }}"
      exclusive: yes
  sudo:
    hosts: ALL
    as: ALL
    commands: ALL
    nopasswd: yes
```

When using the default settings, the ssh key can be overridden using the
`management_user_key` variable.

It is however recomended to use your own custom user settings. More information
about the available attributes can be found in the documentation of the GROG
[user][grog.user], [authorized-key][grog.authorized-key] and [sudo][grog.sudo]
roles.

## Dependencies

- [GROG.user][grog.user]
- [GROG.authorized-key][grog.authorized-key]
- [GROG.sudo][grog.sudo]

## Example Playbook

```yaml
---
- hosts: all
  roles:
  - { role: GROG.management-user, become: yes }
```

## Contributing
All assistance, changes or ideas [welcome][issues]!

## Author
By [G. Roggemans][groggemans]

## License
MIT

[galaxy_image]:         http://img.shields.io/badge/galaxy-GROG.management--user-660198.svg?style=flat
[galaxy_link]:          https://galaxy.ansible.com/GROG/management-user
[travis_image]:         https://travis-ci.org/GROG/ansible-role-management-user.svg?branch=master
[travis_link]:          https://travis-ci.org/GROG/ansible-role-management-user
[tag_image]:            https://img.shields.io/github/tag/GROG/ansible-role-management-user.svg
[tag_url]:              https://github.com/GROG/ansible-role-management-user/tags
[gitter_image]:         https://badges.gitter.im/GROG/chat.svg
[gitter_url]:           https://gitter.im/GROG/chat

[grog.user]:            https://galaxy.ansible.com/GROG/user
[grog.authorized-key]:  https://galaxy.ansible.com/GROG/authorized-key
[grog.sudo]:            https://galaxy.ansible.com/GROG/sudo

[issues]:               https://github.com/GROG/ansible-role-management-user/issues
[groggemans]:           https://github.com/groggemans
