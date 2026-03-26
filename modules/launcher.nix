{ pkgs, lib, ... }:

{
  options.sysopts.launcher = lib.mkOption {
    type = lib.types.str;
    default = "qs ipc call launcher toggle";
    readOnly = true;
    description = "Sys launcher";
  };

  config = {
    programs.fuzzel.enable = false;
  };
}
