{
  lib,
  config,
  ...
}:
let
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.lists) optional;
  cfg = config.custom.zswap;
in
{
  options.custom.zswap = {
    enable = mkEnableOption "zswap memory compression";

    compressor = mkOption {
      type =
        with lib.types;
        nullOr (enum [
          "lzo"
          "lz4"
          "zstd"
        ]);
      default = null;
      description = ''
        Compression algorithm to use:
        - lzo: Fast compression with moderate ratio
        - lz4: Very fast compression, lower ratio (default)
        - zstd: Better compression ratio, slower
        - null: kernel's default.
      '';
    };

    max_pool_percent = mkOption {
      type = with lib.types; nullOr int;
      default = null;
      example = 20;
      description = ''
        Maximum percentage of system RAM that may be taken up by the zswap pool.
        Value should be between 1 and 100.
        Use kernel's default if null.
      '';
    };

    shrinker_enabled = mkOption {
      type = with lib.types; nullOr bool;
      default = null;
      example = true;
      description = ''
        Enable the zswap shrinker which allows the kernel to reclaim memory
        from the zswap pool when system memory is low.
        Use kernel's default if null.
      '';
    };

    same_filled_pages = mkOption {
      type = with lib.types; nullOr bool;
      default = null;
      example = true;
      description = ''
        Enable optimization for same-filled pages. This can improve performance
        when dealing with pages filled with the same value.
        Use kernel's default if null.
      '';
    };

    zpool = mkOption {
      type =
        with lib.types;
        nullOr (enum [
          "zbud"
          "z3fold"
          "zsmalloc"
        ]);
      default = null;
      description = ''
        Zpool type to use for zswap:
        - zbud: Simple buddy allocator
        - z3fold: More efficient than zbud
        - zsmalloc: Most space-efficient (recommended)
        - null: Use kernel's default.
      '';
    };

    debug = mkOption {
      type = with lib.types; nullOr bool;
      default = null;
      example = false;
      description = "Enable zswap debug output in kernel logs.";
    };
  };

  config = mkIf cfg.enable {
    warnings =
      [ ]
      ++ optional (
        (builtins.length config.swapDevices) == 0
      ) "zswap: Zswap is useless without configured swap devices";

    assertions = [
      {
        assertion = !config.zramSwap.enable;
        message = "zswap: Don't use zram/zramSwap and zswap together.";
      }
    ];

    # Configure zswap parameters via systemd tmpfiles
    systemd.tmpfiles.rules =
      let
        toTmpfiles = param: value: "w /sys/module/zswap/parameters/${param} - - - - ${toString value}";
        boolToString = val: if val then "Y" else "N";
      in
      [ (toTmpfiles "enabled" "Y") ]
      ++ optional (cfg.compressor != null) (toTmpfiles "compressor" cfg.compressor)
      ++ optional (cfg.max_pool_percent != null) (toTmpfiles "max_pool_percent" cfg.max_pool_percent)
      ++ optional (cfg.shrinker_enabled != null) (
        toTmpfiles "shrinker_enabled" (boolToString cfg.shrinker_enabled)
      )
      ++ optional (cfg.same_filled_pages != null) (
        toTmpfiles "same_filled_pages" (boolToString cfg.same_filled_pages)
      )
      ++ optional (cfg.zpool != null) (toTmpfiles "zpool" cfg.zpool)
      ++ optional (cfg.debug != null) (toTmpfiles "debug" (boolToString cfg.debug));

    # Optimized kernel parameters for zswap
    boot.kernel.sysctl = {
      # Prefer zswap over disk swap
      "vm.swappiness" = mkDefault 180;
      # Disable watermark boosting to avoid unnecessary memory pressure
      "vm.watermark_boost_factor" = mkDefault 0;
      # Increase watermark scale factor for better memory management
      "vm.watermark_scale_factor" = mkDefault 125;
      # Reduce page clustering for better compressed page handling
      "vm.page-cluster" = mkDefault 1;
      # Lower dirty background ratio for improved performance
      "vm.dirty_background_ratio" = mkDefault 1;
    };
  };
}
