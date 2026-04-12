{
  # Here is the input.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-crostini.url = "github:aldur/nixos-crostini";
    nixos-crostini.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-crostini, home-manager }@inputs:
    let
      modules = [
        # This is your configuration.
        ./configuration.nix

        # Here is where it gets added to the modules.
        nixos-crostini.nixosModules.default
      ];
    in {
    # This allows you to rebuild while running inside the LXC container.
    # Change to your hostname.
    nixosConfigurations.cave = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = modules;
    };

    # This will allow you to build the image from another host.
    packages = rec {
          lxc = nixos-crostini.inputs.nixos-generators.nixosGenerate {
            inherit modules;
            specialArgs = { inherit inputs; };
            system = "x86_64-linux";
            format = "lxc";
          };
          lxc-metadata = nixos-crostini.inputs.nixos-generators.nixosGenerate {
            inherit modules;
	    system = "x86_64-linux";
            format = "lxc-metadata";
          };

          x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.stdenv.mkDerivation {
            name = "lxc-image-and-metadata";
            dontUnpack = true;

            installPhase = ''
              mkdir -p $out
              ln -s ${lxc-metadata}/tarball/*.tar.xz $out/metadata.tar.xz
              ln -s ${lxc}/tarball/*.tar.xz $out/image.tar.xz
            '';
          };
        };


   # Entrypoint for home directory management
   # This could be a separate flake.nix in a subdirectory, since it's independent from the rest.
   # Install with home-manager --flake .#toni
   homeConfigurations = {
     toni = home-manager.lib.homeManagerConfiguration {
       pkgs = nixpkgs.legacyPackages.x86_64-linux;
       modules = [ ./homes/toni.nix ];
     };
     ttimonen = home-manager.lib.homeManagerConfiguration {
       pkgs = nixpkgs.legacyPackages.x86_64-linux;
       modules = [ ./homes/ttimonen.nix ];
     };
    };
 };
}

