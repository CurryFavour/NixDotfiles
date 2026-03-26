{ pkgs, ... }:

{
  programs.niri = {
    enable = false;
    package = pkgs.niri-unstable;
  };
}
