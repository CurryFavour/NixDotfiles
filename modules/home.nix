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
    inputs.sops-nix.homeManagerModules.sops
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

  home.username = "puppy";
  home.homeDirectory = "/home/puppy";
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
    p7zip
    clang
    kitty
    krita
    lsd
  ];

  sops = {
    defaultSopsFile = ../secrets/github.yaml;
    age.keyFile = "/home/puppy/.config/sops/age/keys.txt";

    secrets = {
      github_token = { };
      git_email = { };
    };
  };

  services.hyprpaper.enable = true;
  programs.prismlauncher.enable = true;
  # services.mako.enable = true; # qs manages my notifs

  programs.git = {
    enable = true;
    userName = "CurryFavour";

    extraConfig = {
      user.email = "$(cat ${config.sops.secrets.git_email.path})";
      credential.helper = "!f() { echo password=$(cat ${config.sops.secrets.github_token.path}); }; f";
      init.defaultBranch = "main";
    };
  };

  gtk.gtk4.theme = config.gtk.theme;
  stylix.targets.qt.enable = false;
}
