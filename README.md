# devops@home

Configuration management of the my personal machines, my dotfiles,
my other somethings. Because why not.

This version is based on [DevOS][devos].

## Setup

You need `nix` to be installed. `direnv` is recommended too, because you need
to be inside `nix shell`.

Preffered way to deploy things is to use [deploy-rs][deploy-rs-guide].

[sops][sops-nix] is used for secrets.

- [How to create installation media][iso-guide]
- [How to install][install-guide]

[Packages](./pkgs), [modules](./modules) and
[home manager modules](./users/modules) are available as flake outputs
for reuse. Type `nix flake show` for TOC.

[mit]: https://mit-license.org
[devos]: https://devos.divnix.com/doc/start
[deproy-rs-guide]: https://devos.divnix.com/integrations/deploy.html
[iso-guide]: https://devos.divnix.com/flk/iso.html
[install-guide]: https://devos.divnix.com/flk/install.html
[sops-nix]: https://github.com/Mic92/sops-nix
