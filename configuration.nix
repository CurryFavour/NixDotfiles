{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    plymouth = {
      enable = true;
    };

    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "udev.log_level=3"
      "systemd.show_status=auto"
    ];
    kernelModules = [
    ];
    loader.timeout = 0;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  hardware = {
    opentabletdriver.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  networking.hostName = "luccaww";
  networking.networkmanager.enable = true;

  time.timeZone = "Brazil/East";

  services.printing.enable = false;
  services.openssh = {
    enable = true;
  };

  services.tor = {
    enable = true;
    openFirewall = false;
  };

  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.config.allowUnfree = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.libinput.enable = true;
  services.upower.enable = true;

  services.displayManager.ly.enable = true;

  services.keyd = {
    enable = true;
    keyboards = {
      internal_keyboard = {
        ids = [ "0001:0001:09b4e68d" ];
        settings = {
          main = {
            capslock = "layer(mouse)";
            leftalt = "layer(brokey)"; # Keyboard brokes
          };

          mouse = {
            j = "leftmouse";
            k = "rightmouse";
          };

          brokey = {
            u = "o";
            i = "p";
            k = "l";
            m = ".";
            "[" = "'";
            "8" = "9";
          };
        };
      };
    };
  };

  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  users.users.nya = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      firefox
      kitty
      tree
    ];
  };

  stylix = {
    enable = true;
    image = ./Wallpapers/gruvbox_light_linux.png;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-light-soft.yaml";
    override = {
      base00 = "e1d6a9";
      base01 = "e1d6a9";
    };
    polarity = "dark";
    autoEnable = true;

    icons = {
      enable = true;
      package = pkgs.gruvbox-plus-icons;
      dark = "Gruvbox-Plus-Dark";
      light = "Gruvbox-Plus-Light";
    };

    fonts = { };
    cursor = {
      package = pkgs.capitaine-cursors-themed;
      name = "Capitaine Cursors (Gruvbox) - White";
      size = 16;
    };

  };

  programs.hyprland.enable = true;
  programs.zsh.enable = true;

  programs.steam.enable = true; # No HM module :(

  system.stateVersion = "25.11";
}
