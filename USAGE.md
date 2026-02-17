# Usage Guide

## New Host Installation

### Create installation media

```bash
# Build headless installation ISO
nix build .#nixosConfigurations.iso-headless.config.system.build.isoImage
# ISO will be available in result/iso/
ls -la result/iso/*.iso
```

### Flash to USB Drive

Flash `result/iso/*.iso` to USB drive (use `dd` or `usbimager`).

```bash
# Using dd (Linux/macOS)
sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress
```

### Boot target machine

Boot the NixOS installer ISO. Check that you can connect to the machine via SSH.
Key based authentication is enabled.

### Prepare Secrets

Generate SSH host keys for a new machine:

```bash
mkdir -p /tmp/newroot/state/etc/ssh
ssh-keygen -A -f /tmp/newroot/state
```

Use `/tmp/newroot/state` for ssh keys if state opt-in ("impermanence") is used.
Otherwise, use `/tmp/newroot`.

Get the machine's public AGE key from the host SSH ed25519 key:

```bash
nix-shell -p ssh-to-age \
  --run 'ssh-to-age -i /tmp/newroot/state/etc/ssh/ssh_host_ed25519_key.pub'
```

Add this key to `.sops.yaml` and create `secrets/<hostname>.yaml`. Edit secrets
via `sops edit secrets/<hostname>.yaml`.

#### Deploy Remotely

Deploy the system:

```bash
nixos-anywhere -f .#<hostname> \
  --target-host root@<TARGET_IP> \
  --extra-files /tmp/newroot
```

### Post-Installation Setup

Connect to the new machine's console and enter the disk encryption key. Connect
to the machine via SSH. Reconfigure the disk encryption:

```bash
systemd-cryptenroll /dev/<target_luks_partition> \
  --wipe-slot=password --password
systemd-cryptenroll /dev/<target_luks_partition> \
  --wipe-slot=recovery --recovery
```

If you need passwordless TPM2 unlocking of LUKS devices read the documentation
of the `modules/nixos/system/identity.nix` module.

## System Management

### Daily Operations

**Update system**:

```bash
# Update flake inputs
nix flake update

# Update packages
update-packages --all
# or update specific package
update-packages package-name --argstr commit true

# Rebuild and switch
nh os switch .
# Or apply changes to the remote system
nh os switch -H <remote_hostname> --target-host <remote_host> .
```

### Development Workflows

**Enter development environment**:

```bash
devenv shell
```

**CI / formatting / checks**:

Run formatting and checks via the repo tooling (the exact commands are defined
in `devenv.nix` / `devenv.yaml`):

```bash
# Format the repo
nix fmt
# or just
treefmt

# Run checks
nix flake check

# Run pre-commit checks
prek -V
```

### Secrets Management

Current user's AGE key is most likely at `~/.config/sops/age/keys.txt`.

The matching of keys and files is described in the `.sops.yaml` file.

**Edit Secrets**:

```bash
# Edit host-specific secrets
sops edit secrets/$(hostname).yaml
```

**Rotate Keys**:

```bash
# Generate new age key
age-keygen -o ~/.age/new-key.txt

# Update .sops.yaml with new key
# Re-encrypt affected secrets
sops updatekeys secrets/hostname.yaml
```

## Backup and Recovery

### Backup Procedures

Backup tooling is host-dependent and still evolving.

- For current state: see each host’s configuration under
  `configurations/<host>/` (e.g. `restic.nix`).

**ZFS Snapshots** (alien):

```bash
# Manual snapshot
zfs snapshot pool/dataset@manual-$(date +%Y%m%d)

# List snapshots
zfs list -t snapshot

# Restore from snapshot
zfs rollback pool/dataset@snapshot-name
```

**Btrfs Snapshots** (rog):

```bash
# Manual snapshot
btrfs subvolume snapshot / /snapshots/manual-$(date +%Y%m%d)

# List snapshots
btrfs subvolume list /

# Restore from snapshot
# Boot from previous generation or recovery media
```

### Recovery Procedures

**Boot from Previous Generation**:

1. Select previous generation in boot menu
1. System automatically uses previous configuration
1. Fix issues and rebuild (redeploy - push new configuration)

**Emergency Recovery**:

1. Boot from installation media
1. Mount encrypted storage with recovery key
1. True to repair

**Complete System Recovery**:

1. Boot installation media
1. Backup if needed
1. Partition storage according to host configuration
1. Run `nixos-anywhere` with current configuration
1. Restore data from backups

## Monitoring and Maintenance

### System Health

**Automated Maintenance**:

- Nix garbage collection runs periodically
- Btrfs/ZFS scrubs runs periodically
- Filsesystem snapshot cleanup
- Backups
