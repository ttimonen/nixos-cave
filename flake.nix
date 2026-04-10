{
  # Here is the input.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-crostini.url = "github:aldur/nixos-crostini";
    nixos-crostini.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixos-crostini }: {
    # This allows you to rebuild while running inside the LXC container.
    # Change to your hostname.
    nixosConfigurations.cave = nixpkgs.lib.nixosSystem {
      modules = [
        # This is your configuration.
        ./configuration.nix

        # Here is where it gets added to the modules.
        nixos-crostini.nixosModules.default
      ];
    };

    # This will allow you to build the image from another host.
    packages.x86_64-linux.lxc-image-and-metadata = nixos-crostini.packages.x86_64-linux.default;
  };
}

