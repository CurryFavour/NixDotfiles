{ pkgs, lib, ... }:

{
  options = {
    sysopts.terminal = lib.mkOption {
      type = lib.types.str;
      default = "${pkgs.kitty}/bin/kitty";
      readOnly = true;
      description = "Default terminal emulator";
    };
    
    sysopts.shell = lib.mkOption {
      type = lib.types.str;
      default = "${pkgs.zsh}/bin/zsh";
      readOnly = true;
      description = "Default shell";
    };
  };

  config = {
    programs.kitty = {
      enable = true;

      extraConfig = ''
        enable_audio_bell no
        visual_bell_duration 0
        window_alert_on_bell no
        confirm_os_window_close 0
        window_padding_width 10
      '';
    };

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        # Garbage collection
        nclean = "sudo nix-collect-garbage -d";

        # Quick navigation
        dots = "cd ~/nixfiles";

        # Helper aliases
        ls = "lsd --color=auto";
        grep = "grep --color=auto";
        # cd = "z";
        # FUTURE ME: qsd is just an easy to type alias
        # no further meaning :P
        qsd = "sudo nixos-rebuild switch --flake .#lucca";
      };

      oh-my-zsh = {
        enable = true;
        plugins = [
          "sudo"
          "vi-mode"
        ];
        theme = "smt";
      };

    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--cmd cd"
      ];
    };
  };
}
