#
# Some common configuration of preservation.
#
{ inputs, self, ... }:
{
  imports = [ inputs.preservation.nixosModules.preservation ];

  fileSystems."/state".neededForBoot = true;

  preservation = {
    preserveAt."/state" = self.lib.preservationPolicies.commonSystemPresertveAt;
  };

  systemd.services.systemd-machine-id-commit = {
    unitConfig.ConditionPathIsMountPoint = [
      ""
      "/state/etc/machine-id"
    ];
    serviceConfig.ExecStart = [
      ""
      "systemd-machine-id-setup --commit --root /state"
    ];
  };
}
