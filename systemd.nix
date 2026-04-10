{ config, pkgs, ... }:
let
  oldNixpkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/d3736636ac39ed678e557977b65d620ca75142d0.tar.gz";
    sha256 = "0qr3xiilqgsrsid4yyw66aj9bm4x4j911pqkkq4cpkp9sc22bxc9";
  }) { config = config.nixpkgs.config; system = pkgs.system; };
in
{
  # Insert the overlay
  nixpkgs.overlays = [
    (final: prev: {
      systemd = let
        # The list of arguments modern nixpkgs passes that old systemd doesn't understand
        unsupportedArgs = [ "withVConsole"  "withNspawn" ];

        # A recursive function that intercepts `.override` calls to strip out unsupported arguments
        wrapOverride = drv: drv // {
	  withVConsole = true;
          withNspawn = true;
          withTpm2Units = false;
          override = args: wrapOverride (drv.override (
            builtins.removeAttrs args unsupportedArgs
          ));
        };

        # Hook into the old package's build phase to create the missing directory
        patchedSystemd = oldNixpkgs.systemd.overrideAttrs (oldAttrs: {
          postInstall = (oldAttrs.postInstall or "") + ''
            # Satisfy modern NixOS module path expectations
            mkdir -p $out/example/systemd/system/factory-reset.target.wants
          '';
        });
      in 
        wrapOverride patchedSystemd;
    })
  ];

  systemd.suppressedSystemUnits = [ "systemd-factory-reset-request.service" "systemd-factory-reset-reboot.service" "factory-reset-target.wants" ];


}
