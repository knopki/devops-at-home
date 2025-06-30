{ self, ... }:
{
  imports = with self.modules.homeManager; [
    profiles-legacy-base
  ];

  home.stateVersion = "20.09";
}
