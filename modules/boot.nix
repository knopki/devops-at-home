{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.boot;
in
{
  options.boot = {
    nonLocalBinds = mkEnableOption "Allow bind to non-local IP addresses";
    rebootOnPanicOrOOM = mkEnableOption "Panic or OOM leads to reboot";
    latestKernel = mkEnableOption "Use latest kernel package";
    disableSecurityMitigations = mkEnableOption "Make Linux fast againt";
    optimizeForWorkstation = mkEnableOption "Enable workstation optimizations";
  };

  config.boot = {
    kernel.sysctl = (
      optionalAttrs cfg.nonLocalBinds {
        "net.ipv4.ip_nonlocal_bind" = 1;
        "net.ipv6.ip_nonlocal_bind" = 1;
      }
    ) // (
      optionalAttrs cfg.rebootOnPanicOrOOM {
        "kernel.panic_on_oops" = 1;
        "kernel.panic" = 20;
        "vm.panic_on_oom" = 1;
      }
    ) // (
      optionalAttrs cfg.optimizeForWorkstation {
        "fs.inotify.max_user_watches" = 524288;
      }
    );

    kernelPackages = mkIf cfg.latestKernel (mkDefault pkgs.linuxPackages_latest);

    kernelParams = optional cfg.disableSecurityMitigations "mitigations=off"
    ++ (optionals cfg.optimizeForWorkstation [ "quiet" "splash" "nohz_full=1-7" ]);

    tmpOnTmpfs = mkIf cfg.optimizeForWorkstation (mkDefault true);
    disableSecurityMitigations = mkIf cfg.optimizeForWorkstation (mkDefault true);
    nonLocalBinds = mkIf cfg.optimizeForWorkstation (mkDefault true);
    rebootOnPanicOrOOM = mkIf cfg.optimizeForWorkstation (mkDefault true);
  };
}
