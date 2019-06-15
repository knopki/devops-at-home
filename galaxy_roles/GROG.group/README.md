# Group

[![Ansible Galaxy][galaxy_image]][galaxy_link]
[![Build Status][travis_image]][travis_link]
[![Latest tag][tag_image]][tag_url]
[![Gitter chat][gitter_image]][gitter_url]

A role for managing groups.

## Requirements

- Hosts should be bootstrapped for ansible usage (have python,...)
- Root privileges, eg `become: yes`
- `groupadd`, `groupdel` and `groupmod` should be available on the host

## Role Variables

| Variable | Description | Default value |
|----------|-------------|---------------|
| `group_list` | List of groups **(see details!)** | `[]` |
| `group_list_host`| List of groups **(see details!)**  | `[]` |
| `group_list_group` | List of groups **(see details!)** | `[]` |
| `group_state` | Default group state | `present` |
| `group_system` | Default group system state | `no` |

#### `group_list` details

`group_list`, `group_list_host` and `group_list_group` are merged when
managing the groups. You can use the host and group lists to specify
groups per host or group off hosts.

The group list allows you to define which groups must be managed. Each item in
the list can have following attributes:

| Variable | Description | Required |
|----------|-------------|----------|
| `name` | Group name | yes |
| `gid` | Group id | no |
| `state` | Group state | no |
| `system` | System group? | no |

###### Example `group_list`

```yaml
group_list:
  - name: group1
  - name: group2
    gid: 1001
    system: yes
  - name: group3
    gid: 1002
    state: absent
```

## Dependencies

None.

## Example Playbook

```yaml
---
- hosts: servers
  roles:
  - { role: GROG.group
      become: yes,
        group_list: [
          { name: group1,
            state: present },
          { name: group2,
            gid: 1001 }
        ]
    }
```

## Contributing
All assistance, changes or ideas [welcome][issues]!

## Author
By [G. Roggemans][groggemans]

## License
MIT

[galaxy_image]:         http://img.shields.io/badge/galaxy-GROG.group-660198.svg?style=flat
[galaxy_link]:          https://galaxy.ansible.com/GROG/group
[travis_image]:         https://travis-ci.org/GROG/ansible-role-group.svg?branch=master
[travis_link]:          https://travis-ci.org/GROG/ansible-role-group
[tag_image]:            https://img.shields.io/github/tag/GROG/ansible-role-group.svg
[tag_url]:              https://github.com/GROG/ansible-role-group/tags
[gitter_image]:         https://badges.gitter.im/GROG/chat.svg
[gitter_url]:           https://gitter.im/GROG/chat

[issues]:               https://github.com/GROG/ansible-role-group/issues
[groggemans]:           https://github.com/groggemans
