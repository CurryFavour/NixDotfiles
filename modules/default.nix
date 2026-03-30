{
  pkgs,
  lib,
  config,
  ...
}:


/*
 * This file is meant to hold system-wide options 
 * that are not specific to any particular module
 * for the sake of organization. >.<
 */

{
  options.sysopts = {
    screenshot = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      directory = lib.mkOption {
        type = lib.types.str;
        default = "~/Pictures/Screenshots";
        description = "Directory where screenshots will be saved";
      };
      exec = lib.mkOption {
        type = lib.types.str;
        default = "hyprshot -m region -z -o ${config.sysopts.screenshot.directory}";
        readOnly = true;
      };
    };

    colorpicker = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      exec = lib.mkOption {
        type = lib.types.str;
        default = "hyprpicker -a";
        readOnly = true;
      };
    };
  };

  config = {
    home.packages =
      (lib.optional config.sysopts.screenshot.enable pkgs.hyprshot)
      ++ (lib.optional config.sysopts.colorpicker.enable pkgs.hyprpicker);
  };
}
