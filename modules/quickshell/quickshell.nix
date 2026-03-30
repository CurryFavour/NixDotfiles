{ config, pkgs, ... }:

let
  c = config.lib.stylix.colors.withHashtag;

  themedQtObject = pkgs.writeText "Theme.qml" ''
    import QtQuick

    QtObject {
        property color base00: "${c.base00}"
        property color base01: "${c.base01}"
        property color base02: "${c.base02}"
        property color base03: "${c.base03}"
        property color base04: "${c.base04}"
        property color base05: "${c.base05}"
        property color base06: "${c.base06}"
        property color base07: "${c.base07}"
        property color base08: "${c.base08}"
        property color base09: "${c.base09}"
        property color base0A: "${c.base0A}"
        property color base0B: "${c.base0B}"
        property color base0C: "${c.base0C}"
        property color base0D: "${c.base0D}"
        property color base0E: "${c.base0E}"
        property color base0F: "${c.base0F}"

        property color bg:           base00
        property color bgDim:        base01
        property color bgHover:      base02
        property color bgFocus:      base03
        property color fg:           base07
        property color fgMuted:      base04
        property color fgDim:        base05
        property color fgFocus:      base06
        
        property color red:          base08
        property color orange:       base09
        property color yellow:       base0A
        property color green:        base0B
        property color cyan:         base0C
        property color blue:         base0D
        property color purple:       base0E
        property color brown:        base0F
        
        property color highlight:    base00
        property color shadow:       base07
        property color border:       base03
        property color selection:    base0D
        
        property color launcherBg:           base07
        property color launcherPrompt:       base0B
        property color launcherText:         base01
        property color launcherSelectBlue:   base0D
        
        property color clipboardBg:          base07
        property color clipboardPrompt:      base0B
        property color clipboardText:        base01
        
        property color topbarBg:             base07
        property color topbarWidgetBg:       base07
        property color topbarSliderBg:       base07
        property color topbarClockBg:        base07
    }
  '';

  # Need to build a single dir, cause otherwise qs will look in the nix store .-.
  quickshell-config = pkgs.runCommand "quickshell-config" {} ''
    mkdir -p $out
    
    cp -r ${./Components} $out/Components
    cp -r ${./Panels} $out/Panels
    cp -r ${./Services} $out/Services
    cp -r ${./Widgets} $out/Widgets
    cp    ${./shell.qml} $out/shell.qml

    cp ${themedQtObject} $out/Theme.qml
  '';
in
{
  home.packages = [ pkgs.quickshell ];

  xdg.configFile."quickshell" = {
    source = quickshell-config;
    recursive = true;
  };

  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell Desktop Component";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.quickshell}/bin/quickshell --path ${config.xdg.configHome}/quickshell/shell.qml";
      Restart = "never";
      RestartSec = "2";
    };
    Install = { WantedBy = [ "graphical-session.target" ]; };
  };
}