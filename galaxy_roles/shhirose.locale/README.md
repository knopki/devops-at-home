# ansible-locale

[![Build Status](https://travis-ci.org/shhirose/ansible-locale.svg?branch=master)](https://travis-ci.org/shhirose/ansible-locale)
[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)

This is Ansible role for change locale for RedHat Enterprise Linux, Ubuntu and Debian.

## Requirements

None

## Role Variables

* shhirose\_locale\_locale - The value for variable LANG

## Dependencies

None

## Example Playbook

Example:

```yaml
- hosts: servers
  become: yes
  roles:
     - { role: shhirose.locale }
  vars:
    shhirose_locale_locale: "ja_JP.UTF-8"
```

Result (CentOS):

```
$ sudo localectl
   System Locale: LANG=ja_JP.UTF-8
       VC Keymap: us
      X11 Layout: n/a
```

## License

MIT
