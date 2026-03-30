{
  pkgs,
  config,
  lib,
  ...
}:

{
  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      monitor = ",preferred,auto,1";

      general = {
        gaps_in = 10;
        gaps_out = 15;
        border_size = 1;
        layout = "master";

        "col.active_border" = lib.mkForce "rgb(${config.lib.stylix.colors.base05})";
        "col.inactive_border" = lib.mkForce "rgb(${config.lib.stylix.colors.base00})";
      };

      exec-once = [
        "cliphist"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        # "noctalia-shell"
      ];

      decoration = {
        rounding = 0;
        active_opacity = 1;
        inactive_opacity = 1;
        blur = {
          enabled = false;
          size = 3;
          passes = 2;
        };
      };

      animations = {
        enabled = true;

        bezier = [
          "overshoot, 0.05, 0.9, 0.1, 1.1"
          "spring, 0.22, 1, 0.36, 1"
          "shubunkin, 0, 0.85, 0.3, 1"
        ];

        animation = [
          "windows, 1, 5, overshoot, popin 80%"
          "windowsOut, 1, 5, spring, popin 80%"
          "windowsMove, 1, 4, shubunkin"

          "fade, 1, 5, spring"

          "border, 1, 10, spring"
          "borderangle, 1, 100, spring, loop"

          "workspaces, 1, 6, overshoot, slide"
          "specialWorkspace, 1, 5, overshoot, slidevert"
        ];
      };

      input = {
        kb_layout = "us, br";
        kb_options = "grp:alts_toggle";
        follow_mouse = 1;
        sensitivity = 0.4;
        touchpad = {
          natural_scroll = true;
        };
      };

      # Defaults
      "$mainMod" = "SUPER";
      "$terminal" = config.sysopts.terminal;
      "$launcher" = config.sysopts.launcher;
      "$browser" = "firefox";
      "$clipboardview" = "qs ipc call clipboard toggle";
      "$notificationview" = "qs ipc call notification toggle";
      "$wallpaperselector" = "$ipc wallpaper toggle";
      "$screenshot" = config.sysopts.screenshot.exec;
      "$colorpicker" = config.sysopts.colorpicker.exec;
      "$restartshell" = "pkill .quickshell-wra || qs";
      "$audioup" = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
      "$audiodown" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
      "$audiomute" = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      "$audiomicmute" = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
      "$brightnessup" = "brightnessctl -e4 -n2 set 5%+";
      "$brightnessdown" = "brightnessctl -e4 -n2 set 5%-";
      "$audioplaypause" = "playerctl play-pause";
      "$audioplaynext" = "playerctl next";
      "$audioplayprev" = "playerctl previous";
      "$kaomoji" = "cat kaolist.*.txt | rofi -dmenu -i -p 'kaomoji' | wl-copy";

      bind = [
        "$mainMod, T,       exec, $terminal"
        "$mainMod, A,       exec, $launcher"
        "$mainMod, V,       exec, $clipboardview"
        "$mainMod, B,       exec, $notificationview"
        "$mainMod, U,       exec, $kaomoji"
        "$mainMod, Space,   exec, $launcher"
        "$mainMod, R,       exec, $wallpaperselector"
        "$mainMod, N,       exec, $screenshot"
        "$mainMod, C,       exec, $colorpicker"
        "Control, Escape,   exec, $restartshell"
        "$mainMod, W,       togglefloating,"
        "$mainMod, G,       togglesplit,"
        "$mainMod, F,       fullscreen,"
        "$mainMod, Q,       killactive,"
        "$mainMod Alt, M,   exit,"

        "$mainMod, H, movefocus, l"
        "$mainMod, L, movefocus, r"
        "$mainMod, K, movefocus, u"
        "$mainMod, J, movefocus, d"

        "$mainMod SHIFT, H, movewindow, l"
        "$mainMod SHIFT, L, movewindow, r"
        "$mainMod SHIFT, K, movewindow, u"
        "$mainMod SHIFT, J, movewindow, d"

        "$mainMod Control, H, resizeactive, -20 0"
        "$mainMod Control, L, resizeactive, 20 0"
        "$mainMod Control, K, resizeactive, 0 -20"
        "$mainMod Control, J, resizeactive, 0 20"

        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        "$mainMod SHIFT, S, movetoworkspace, special"

        ",XF86AudioRaiseVolume,   exec, $audioup"
        ",XF86AudioLowerVolume,   exec, $audiodown"
        ",XF86AudioMute,          exec, $audiomute"
        ",XF86AudioMicMute,       exec, $audiomicmute"
        ",XF86MonBrightnessUp,    exec, $brightnessup"
        ",XF86MonBrightnessDown,  exec, $brightnessdown"
        ",XF86AudioNext,          exec, $audioplaynext"
        ",XF86AudioPause,         exec, $audioplaypause"
        ",XF86AudioPlay,          exec, $audioplaypause"
        ",XF86AudioPrev,          exec, $audioplayprev"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };
}
