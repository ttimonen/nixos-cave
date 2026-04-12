{ ... }:
{
  home.username = "toni";
  home.homeDirectory = "/home/toni";

  programs.git = {
	enable = true;
	settings.user.name = "Toni Timonen";
	settings.user.email = "toni.timonen@iki.fi";
  };

  programs.bash.enable = true;
  programs.fish.enable = true;
  programs.nushell.enable = true;
  programs.vim = {
    enable = true;
    defaultEditor = true;
  };





  programs.home-manager.enable = true;
  home.stateVersion = "25.11";
}
