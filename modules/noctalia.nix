{ pkgs, inputs, ... }:

/* FUTURE ME:
 *  Remember to uncomment the flake inputs */
{
  programs.noctalia-shell = {
    enable = true;
    settings = {
      general = {
        scaleRatio = 0.95;
        radiusRatio = 0.2;
        performanceMode = false;
        enableShadows = false;
      };

      location = {
        monthBeforeDay = false;
        name = "";
      };

      dock = {
        enabled = false;
      };

      appLauncher = {
        enableClipboardHistory = false;
        autoPasteClipboard = false;
        enableClipPreview = true;
        clipboardWrapText = true;
        position = "bottom-center";
      };

      bar = {
        bartype = "frame";
        position = "bottom";
        density = "compact";
        floating = false;
        showOutline = false;
        showCapsule = true;
        # backgroundOpacity = 1;
        marginVertical = 8;
        marginHorizontal = 8;
        outerCorners = true;

        widgets = {
          left = [
            {
              id = "ControlCenter";
              useDistroLogo = false;
              icon = "paw-filled";
            }
            { id = "Network"; }
            { id = "Bluetooth"; }
          ];
          center = [
            {
              id = "Workspace";
              labelMode = "none";
              hideUnoccupied = false;
            }
          ];
          right = [
            { id = "Media"; }
            {
              id = "Battery";
              displayMode = "icon-clean";
              alwaysShowPercentage = false;
              warningThreshold = 30;
            }
            {
              id = "Clock";
              formatHorizontal = "HH:mm";
              useMonospacedFont = true;
            }
            {
              id = "tray";
            }
          ];
        };
      };
    };
  };
}
