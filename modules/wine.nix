{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    wineWow64Packages.stable
    winetricks
  ];

  home.sessionVariables = {
    WINEPREFIX = "${config.home.homeDirectory}/.wine-prefix";
  };
}
