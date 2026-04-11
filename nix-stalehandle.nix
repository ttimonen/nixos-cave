{ config, pkgs, lib, ... }:

{
  # Add this to your existing overlays
  nixpkgs.overlays = [
    (final: prev: {
      # nixVersions is an extensible scope, so we use .extend
      nixVersions = prev.nixVersions.extend (nixFinal: nixPrev: {
        # Patch is already in 2.31.4
        nixComponents_2_31 =
          if final.lib.versionOlder nixPrev.nixComponents_2_31.version "2.31.4"
          then
            # Hook into the base components and use the built-in appendPatches
            nixPrev.nixComponents_2_31.appendPatches [
              (final.fetchpatch2 {
                name = "nix-stale-handle.patch";
                url = "https://github.com/NixOS/nix/commit/2e6a03e264007df21c38be3270a4e06b27bf4599.patch?full_index=1";
                hash = "sha256-6JNWUR6RbSkOxheYTcZEW/JxF+7yRpn7r9l3xfAobzI=";
              })
            ]
          else
            nixPrev.nixComponents_2_31;
      });
    })
  ];

  #nix.package = pkgs.nixVersions.nix_2_31;
}
