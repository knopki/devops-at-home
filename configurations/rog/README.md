# ASUS Zephyrus Configuration

**Hardware**: ASUS Zephyrus GA402RJ-L8065

- **CPU**: AMD with integrated AMDGPU
- **Storage**: NVMe with LUKS + Btrfs
- **Features**: TPM2, Secure Boot

## Configuration Details

**Storage Architecture**:

- Full disk encryption with LUKS
- TPM2-based automatic unlocking
- Btrfs with subvolumes
- Separate state preservation

**Key Features**:

- COSMIC desktop environment
- State preservation system
- TPM2 integration
- Development environment

**Disk Layout**:

```text
/dev/nvme0n1p1  -> /boot (vfat, 1GB)
/dev/nvme0n1p2  -> LUKS container
  └── LVM volume group
      ├── swap (40GB)
      ├── sys (200GB, Btrfs)
      ├── state (remaining space, Btrfs)
      └── sensitive (1GB, Btrfs)
```

**Preservation Paths**:

- `/state` - Persistent data across reboots
- User data, system configuration, logs
- SSH keys and secrets
