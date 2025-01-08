{ self, ... }:
{
  imports = with self.modules.nixos; [ home-manager ];
}
