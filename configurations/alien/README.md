# Alienware Laptop Configuration

Laptop from 2014. Very old installation of NixOS (2019?).

**Hardware**: Dell Alienware 15 R2

- **CPU**: Intel with integrated graphics
- **GPU**: Intel (NVIDIA disabled because of instability)
- **Storage**: NVMe SSD with ZFS
- **Network**: WiFi + Ethernet

### Configuration Details

**Storage Architecture**:

- Boot: UEFI boot partition
- Root: Full disk encryption with LUKS
- Data: ZFS pool with encryption
- Backup: Automated snapshots with Sanoid, replication with Syncoid + offsite backup with kopia

**Key Features**:

- Full desktop environment (Cosmic DE)
- Development tools and IDEs
- Container runtime (Podman)
- Media applications
- Office suite
- VPN client (AmneziaWG)

**Services**:

- iSponsorBlockTV
- SSH daemon
- Printing support

**File Systems**:

```
/boot     -> /dev/disk/by-uuid/6964-B539 (vfat)
/         -> /dev/disk/by-uuid/e384e984-... (ext4)
ZFS pools:
  - evo970 home data)
  - wdc2 (private data - detachable)
  - wdc3 (backups - detachable)
```
