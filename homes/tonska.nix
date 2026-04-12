{ ... }:
{
  programs.git = {
	enable = true;
	settings.user.name = "Toni Timonen";
	settings.user.email = "toni.timonen@iki.fi";
  };

  programs = {
    bash.enable = true;
    fish.enable = true;
    nushell.enable = true;
    vim = {
      enable = true;
      defaultEditor = true;
    };
    starship = {
      enable = true;
      enableTransience = true;
      settings = {
        add_newline = false;
        nix_shell.heuristic = true;
        shell.disabled = false;
      };
    };
  };


  programs.home-manager.enable = true;
  home.stateVersion = "25.11";
}
