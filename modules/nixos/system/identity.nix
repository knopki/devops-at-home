/**
  System Identity & Storage Integrity Module

  PURPOSE:
  This module implements a 'Measured Boot' chain for the storage stack.
  It ensures that the LUKS-encrypted partitions are unlocked in
  a deterministic order and that the final system state matches
  a known 'Golden Master' measurement in TPM PCR 15.

  WARNING:
  Any change to the hardware configuration, firmware (UEFI update), or disk
  partition layout may change PCR values. If this happens, TPM-based unlocking
  will fail, and you will be prompted for the recovery passphrase.

  HOW IT WORKS:
  1. Each LUKS device in `luksDevices` is configured to measure its metadata
     into PCR 15.
  2. This module forces a sequential unlock order
     (Device A -> Device B -> Device C).
  3. PCR 15 accumulates these measurements: H(H(H(0) + A) + B) + C.
  4. Before mounting the root filesystem, the module verifies that the runtime
     PCR 15 matches the `pcr15` option.
  5. After verification, it 'seals' PCR 15 by extending it with a runtime value
     to prevent post-boot exploitation.

  INITIAL SETUP / HOW TO GET THE PCR 15 VALUES:
  1. Enable the module: `custom.systemIdentity.enable = true;` and
     list your `luksDevices`.
  2. Set `pcr15 = null;`, enable `debug`, and disable `enableStateTransition`.
     (This allows capturing PCR values before they are modified or hidden).
  3. Boot the system and unlock all drives manually using your passphrase.
  4. Retrieve the PCR 15 values captured before each disk was unlocked:
     $ journalctl -b 0 | grep print-pcr-15
  5. Bind each LUKS device to its specific PCR 15 state:
     $ sudo systemd-cryptenroll /dev/sdX --tpm2-device=auto \
       --tpm2-pcrs=0+2+7+15:sha256=XXX
     (Where XXX is the PCR 15 value recorded *immediately before* unlocking that specific device).
  6. Get the final 'Golden Master' value after all disks are open:
     $ systemd-analyze pcrs 15 --json=short | jq -r '.[0].sha256'
  7. Update your Nix configuration:
     - Set `pcr15` to the value from step 6.
     - Set `debug = false;` and `enableStateTransition = true;`.
  8. Apply configuration and reboot to verify seamless TPM-based unlocking.
*/
{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (builtins)
    all
    hasAttr
    elemAt
    listToAttrs
    ;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.strings) concatLines optionalString toUpper;
  inherit (lib.lists) optional imap0;
  inherit (lib.attrsets) nameValuePair;
  inherit (lib.meta) getExe;

  cfg = config.custom.systemIdentity;

  printPcr15Script = pkgs.writeShellScriptBin "print-pcr-15" ''
    CURRENT_PCR=$(cat /sys/class/tpm/tpm${toString cfg.tpmDevice}/pcr-sha256/15 2>/dev/null || echo unknown)
    echo "PCR 15 is $CURRENT_PCR"
  '';
in
{
  options.custom.systemIdentity = {
    enable = mkEnableOption "Measured Boot integrity enforcement using TPM PCR 15";

    debug = mkEnableOption "PCR 15 logging during initrd execution (disables state transition)";

    pcr15 = mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = ''
        The expected post-unlock SHA-256 hash of PCR 15.

        This value serves as a 'golden master' measurement of the entire
        storage stack integrity. If the runtime PCR 15 doesn't match this
        value, the boot process aborts before mounting the root filesystem.

        Should be a 64 character hex string as output by the sha256 field of
        'systemd-analyze pcrs 15 --json=short'

        If set to null (the default) it will not check the value.
      '';
      example = "6214de8c3d861c4b451acc8c4e24294c95d55bcec516bbf15c077ca3bffb6547";
    };

    tpmDevice = mkOption {
      type = lib.types.int;
      default = 0;
      description = "Index of the TPM device node (e.g., 0 for /dev/tpm0).";
    };

    enableStateTransition = mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Seal the PCR 15 state after successful verification.

        Extends PCR 15 with a runtime-only value ('sysinit.target') to prevent
        post-boot access to the secrets sealed against the pre-boot state.
      '';
    };

    luksDevices = mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = ''
        Deterministic sequence of LUKS devices to be measured into PCR 15.

        The module enforces a strict sequential activation order. Each device
        measures its metadata into PCR 15 before the next one starts, creating
        a cryptographic chain of trust for the storage layout.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        message = "identity: luksDevices name not found as boot.initrd.luks.devices key";
        assertion = all (name: hasAttr name config.boot.initrd.luks.devices) cfg.luksDevices;
      }
    ];

    warnings = optional cfg.debug "systemIdentity: Debug is enabled. Do not use in production.";

    environment.systemPackages = with pkgs; [
      tpm2-tss
      tpm2-tools
    ];

    boot.initrd.kernelModules = [
      "tpm_tis"
      "tpm_crb"
    ];

    boot.initrd.systemd.enable = true;

    boot.initrd.systemd.storePaths = [ (getExe printPcr15Script) ];

    boot.initrd.systemd.services."verify-sysroot-pcr15" = mkIf (cfg.pcr15 != null) {
      unitConfig = {
        Description = "Verify Root Identity via TPM PCR";
        DefaultDependencies = false;
        FailureAction = "halt-force";
      };
      conflicts = [ "shutdown.target" ];
      after = [
        "cryptsetup.target"
        "tpm2.target"
      ];
      before = [ "shutdown.target" ];
      wantedBy = [ "local-fs-pre.target" ];
      requiredBy = [ "sysroot.mount" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        CURRENT_PCR="$(cat /sys/class/tpm/tpm${toString cfg.tpmDevice}/pcr-sha256/15)"
        echo "Checking PCR 15 value..."
        echo "PCR 15: $CURRENT_PCR"
        if [[ "$CURRENT_PCR" != "${toUpper cfg.pcr15}" ]] ; then
          echo "PCR 15 check failed!"
          exit 1
        fi
        echo "PCR 15 check succeeded"
      '';
    };

    # State Transition
    systemd.services."pcr-sysinit" = mkIf cfg.enableStateTransition {
      unitConfig = {
        Description = "TPM PCR Update for sysinit.target";
        DefaultDependencies = false;
        FailureAction = "halt-force";
      };
      conflicts = [ "shutdown.target" ];
      after = [
        "cryptsetup.target"
        "tpm2.target"
      ];
      before = [
        "sysinit.target"
        "shutdown.target"
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${pkgs.systemd}/lib/systemd/systemd-pcrextend --graceful --pcr=15 "sysinit.target"
      '';
    };

    boot.initrd.luks.devices = listToAttrs (
      map (name: {
        inherit name;
        value.crypttabExtraOpts = [
          "tpm2-device=auto"
          "tpm2-measure-pcr=yes"
        ];
      }) cfg.luksDevices
    );

    boot.initrd.systemd.units =
      let
        # Create dependencies for LUKS devices for determinate hashing of PCR 15
        unitSectionTmpl = prev: ''
          [Unit]
          After=systemd-cryptsetup@${prev}.service
          Requires=systemd-cryptsetup@${prev}.service
        '';
        # Debug logging
        serviceSectionTmpl = ''
          [Service]
          ExecStartPre=${getExe printPcr15Script}
        '';

        mkUnit =
          i: cur:
          let
            prev = if i > 0 then elemAt cfg.luksDevices (i - 1) else null;
            text = concatLines [
              (optionalString (prev != null) (unitSectionTmpl prev))
              (optionalString (cfg.debug) serviceSectionTmpl)
            ];
          in
          nameValuePair "systemd-cryptsetup@${cur}.service" {
            inherit text;
            overrideStrategy = "asDropin";
          };
      in
      listToAttrs (imap0 mkUnit cfg.luksDevices);
  };
}
