import QtQuick
import Quickshell
import Quickshell.Io
import "Panels"
import "Widgets"

ShellRoot {
    id: root

    // Instantiate the Master Palette
    Theme {
        id: globalTheme
    }

    // Connect the terminal command `qs ipc call launcher toggle` to our AppLauncher
    IpcHandler {
        target: "launcher"
        function toggle() {
            launcher.toggleState();
        }
    }

    // Render the Top Bar
    TopBar {
        id: bar
        theme: globalTheme
    }

    // Render the hidden Pop-Up Launcher
    AppLauncher {
        id: launcher
        theme: globalTheme
    }

    ClipboardManager {
        id: clipboardWindow
        theme: globalTheme
    }

    IpcHandler {
        target: "clipboard"
        function toggle() {
            clipboardWindow.toggleState();
        }
    }

    Notifications {
          id: notifications
        theme: globalTheme
    }

    IpcHandler {
        target: "notification"
        function toggle() {
            notifications.toggleState();
        }
    }
}
