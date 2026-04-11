{
  # Here is the input.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-crostini.url = "github:aldur/nixos-crostini";
    nixos-crostini.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixos-crostini }@inputs:
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

  };
}

