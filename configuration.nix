# Originally taken from:
# https://github.com/Misterio77/nix-starter-configs/blob/cd2634edb7742a5b4bbf6520a2403c22be7013c6/minimal/nixos/configuration.nix
# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  # lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    # You can import other NixOS modules here.
    # You can also split up your configuration and import pieces of it here:
    # ./users.nix
    # ./crostini.nix
    ./systemd.nix
    ./nix-stalehandle.nix
  ];

  # Search for additional packages here: https://search.nixos.org/packages
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    toni = {
      isNormalUser = true;
      linger = true;
      extraGroups = [ "wheel" ];
    };
  };

  security.sudo.wheelNeedsPassword = false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";

  # Machine specific stuff
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "cave";

  # Workarounds
  # In particular, nix run nixpkgs#hello seems to spend 5+ seconds on hashing
  # a path again and again on every execution.
  # These flags help. Side effect is that now the installation is not standalone anymore,
  # but fetches things from internet instead.
  system.installer.channel.enable = false;
  nix.channel.enable = false;

  nix = {
    settings.experimental-features = [ "nix-command"  "flakes" ]; # Flake enabling magic

    # Cave is underprovisioned for (re)building the world. Use hopihe as the workhorse.
    settings.substituters = [ "ssh://hopihe?remote-program=/root/.nix-profile/bin/nix-store&trusted=1" ];

    # Add nixpkgs to registry -> 'nix run nixpkgs#hello' uses the same revision as your system
    registry = { nixpkgs.flake = inputs.nixpkgs; };

    ## TODO(ttimonen) Do I need any of this? What breaks without these? Do I care?
    ## Optional: This adds the inputs to your system's legacy @nix-path
    ## Useful for making <nixpkgs> work in non-flake commands
    nixPath = [ "nixpkgs=flake:nixpkgs"] ; 
    # TODO(ttimonen) does this work or should do something like
    #  nixPath = [ "nixpkgs=${inputs.nixpkgs.outPath}" ]; instead?
    # Workaround for https://github.com/NixOS/nix/issues/9574
    settings.nix-path = config.nix.nixPath;
 };
}
