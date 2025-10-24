# Instructions for AI agents

## Design Principles

- Try to manage configuration via `nix`

- This project is Flake-based: All inputs pinned with lock file

- `flake-parts` library is used to simplify flake-related chores

- Secrets Management: SOPS for encrypted secrets with age keys

- Host Configurations: Each machine has its own configuration directory

- Reusable Modules: Common functionality extracted into modules

- Profile System: Layered profiles
  (common → server/workstation → more specific roles)

- Immutable Infrastructure: Declarative configuration management

- Version Control: All configuration tracked in Git

- Minimal Attack Surface: Only required services enabled

- Secure Defaults: Security-focused module configurations

## Dev environment tips

- Before you start, check out the other `*.md` files in this repository.
- Start development shell by executing `nix develop` at the root of the project
- Use `nil` and `nixd` language servers if supported
- Ignore and do not read the `flake.lock` file unless it is necessary - it is just a lock file.
- Do not read into this directories: `.direnv`, `.zed`.
- Go into `result` directory only if you really want to see build outputs.

## PR instructions

- Always run `nix flake check` before committing.
- Use the Conventional Commits specification for commit messages
