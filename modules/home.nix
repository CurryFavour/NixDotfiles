{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.nixcord.homeModules.nixcord
    inputs.nixvim.homeModules.nixvim
    inputs.niri.homeModules.niri
    ./quickshell/quickshell.nix
    ./hyprland.nix
    ./terminal.nix
    ./launcher.nix
    ./nixcord.nix
    ./browser.nix
    ./default.nix
    ./editor.nix
    ./niri.nix
    ./wine.nix
  ];

  home.username = "nya";
  home.homeDirectory = "/home/nya";
  home.stateVersion = "25.11";

  home.sessionVariables = {
    XCURSOR_THEME = config.stylix.cursor.name;
    XCURSOR_SIZE = toString config.stylix.cursor.size;
  };

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    nerd-fonts.victor-mono
    nerd-fonts.fira-code
    # nerd-fonts.gohufont
    brightnessctl
    wl-clipboard
    quickshell
    fastfetch
    filezilla # just for the mc server >.>
    discordo
    cliphist
    windsurf
    blender
    hyfetch # Gay af
    hannom
    gowall
    p7zip
    clang
    kitty
    krita
    lsd
  ];

  services.hyprpaper.enable = false;
  services.swww.enable = true;
  programs.prismlauncher.enable = true;
  # services.mako.enable = true; # qs manages my notifs

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "CurryFavour";
      };
      init.defaultBranch = "main";
    };
  };

  gtk.gtk4.theme = config.gtk.theme;
  stylix.targets = {
    qt.enable = false;
    hyprland.hyprpaper.enable = false;
  };
}
