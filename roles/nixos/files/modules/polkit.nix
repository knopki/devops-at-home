{
  security.polkit.extraConfig = ''
    /* Allow users in wheel group to manage systemd units without authentication */
    polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units" &&
            subject.isInGroup("wheel")) {
            return polkit.Result.YES;
        }
    });
  '';
}
