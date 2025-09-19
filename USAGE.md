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

Get a machine's public AGE key from the host SSH keys:

```bash
nix-shell -p ssh-to-age --run 'ssh-keyscan <TARGET_IP> | ssh-to-age'
```

Add this key to `.sops.yaml` and create `secrets/<hostname>.yaml`.
Edit secrets via `sops edit secrets/<hostname>.yaml`.

#### Deploy Remotely

Create a temporary disk encryption key:

```bash
openssl rand -base64 32 > /tmp/disk.key
chmod 600 /tmp/disk.key
```

Deploy the system:
```bash
nixos-anywhere -f .#<hostname> --copy-host-keys \
  --disk-encryption-keys /tmp/disk.key /tmp/disk.key \  --target-host root@<TARGET_IP>
```

### Post-Installation Setup

Connect to the new machine's console and enter the disk encryption key.
Connect to the machine via SSH. Reconfigure the disk encryption:

```bash
systemd-cryptenroll /dev/<target_luks_partition> --password
systemd-cryptenroll /dev/<target_luks_partition> --recovery
systemd-cryptenroll /dev/<target_luks_partition> \
  --tpm2-device=auto \
  --tpm2-pcrs=0+2+7+12 \
  --tpm2-with-pin=true
  # TODO: FIDO2
```

## System Management

### Daily Operations

**Update System**:
```bash
# Update flake inputs
nix flake update

# Update packages
update-packages --all
# or update specific package
update-packages package-name --argstr commit true

# Rebuild and switch
nh os switch .
# or apply changes to the remote system
nh os switch -H <remote_hostname> --target-host <remote_host> .
```

### Development Workflows

**Enter Development Environment**:

```bash
# Enter default project's shell
nix develop
# or
nix develop .#nixos
# or some other project specific shell
nix develop .#<name>

# Or with direnv
echo "use flake <path to this repo>#shell-name" > .envrc
direnv allow
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

TODO: `btrbk`, `kopia`/`restic`/`plakar` guide

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
2. System automatically uses previous configuration
3. Fix issues and rebuild (redeploy - push new configuration)

**Emergency Recovery**:
1. Boot from installation media
2. Mount encrypted storage with recovery key
3. True to repair

**Complete System Recovery**:
1. Boot installation media
2. Backup if needed
3. Partition storage according to host configuration
3. Run `nixos-anywhere` with current configuration
4. Restore data from backups

## Monitoring and Maintenance

### System Health

**Automated Maintenance**:
- Nix garbage collection runs periodically
- Btrfs/ZFS scrubs runs periodically
- Filsesystem snapshot cleanup
- Backups
