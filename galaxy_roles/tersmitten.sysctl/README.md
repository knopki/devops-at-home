## sysctl

[![Build Status](https://travis-ci.org/Oefenweb/ansible-sysctl.svg?branch=master)](https://travis-ci.org/Oefenweb/ansible-sysctl) [![Ansible Galaxy](http://img.shields.io/badge/ansible--galaxy-sysctl-blue.svg)](https://galaxy.ansible.com/tersmitten/sysctl)

Manage `sysctl` settings.

#### Requirements

None

#### Variables

* `sysctl_settings`: [default: `[]`]: List of `sysctl` settings
* `sysctl_settings.{n}.name`: [required]: Name of the setting
* `sysctl_settings.{n}.value`: [required]: Value of the setting
* `sysctl_settings.{n}.state`: [default: `present`]: Whether to ensure the setting is present or absent

## Dependencies

None

#### Example

```yaml
---
- hosts: all
  roles:
    - sysctl
  vars:
    sysctl_settings:
      - name: net.ipv4.tcp_fin_timeout
        value: 10
```

#### License

MIT

#### Author Information

* Mark van Driel
* Mischa ter Smitten

#### Feedback, bug-reports, requests, ...

Are [welcome](https://github.com/Oefenweb/ansible-sysctl/issues)!
