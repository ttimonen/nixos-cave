{ ... }: {
  imports = [ ./tonska.nix ];
  home.username = "toni";
  home.homeDirectory = "/home/toni";
  programs.starship.settings.hostname.ssh_only = false;
}
