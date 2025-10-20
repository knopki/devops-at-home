{ self, ... }:
{
  # Caches in trusted-substituters can be used by unprivileged users i.e. in
  # flakes but are not enabled by default.
  nix.settings.trusted-substituters = [
    "https://nix-community.cachix.org"
    "https://cache.garnix.io"
    "https://numtide.cachix.org"
  ]
  ++ (self.nixConfig.extra-substituters or [ ]);
  nix.settings.trusted-public-keys = [
    "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU="
    "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
  ]
  ++ (self.nixConfig.extra-trusted-public-keys or [ ]);
}
