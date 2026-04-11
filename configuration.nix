# Originally taken from:
# https://github.com/Misterio77/nix-starter-configs/blob/cd2634edb7742a5b4bbf6520a2403c22be7013c6/minimal/nixos/configuration.nix
# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  # lib,
  # config,
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

  # Enable flakes: https://nixos.wiki/wiki/Flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Search for additional packages here: https://search.nixos.org/packages
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    # TODO: Replace `aldur` with the username you picked when configuring Linux
    # in ChromeOS.
    toni = {
      isNormalUser = true;

      linger = true;
      extraGroups = [ "wheel" ];
    };
  };

  security.sudo.wheelNeedsPassword = false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "cave";
  nix = {
    settings.substituters = [ "ssh://hopihe?remote-program=/root/.nix-profile/bin/nix-store&trusted=1" ];
    # This will add each flake input to the registry
    # Making 'nix run nixpkgs#hello' use the same revision as your system
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
    };

    # Optional: This adds the inputs to your system's legacy @nix-path
    # Useful for making <nixpkgs> work in non-flake commands
    nixPath = [ "nixpkgs=${inputs.nixpkgs.outPath}" ];
  };
}
