import QtQuick
import Quickshell
import Quickshell.Io
import "Panels"
import "Widgets"
import "Components"

ShellRoot {
    id: root

    // Modular Shell Container handles all UI components
    ShellContainer {
        id: shellContainer
        anchors.fill: parent
    }
    
    // Top Bar (separate as it's always visible)
    TopBar {
        id: bar
        theme: shellContainer.theme
    }
    
    // IPC Handlers (need to be in main shell context)
    IpcHandler {
        target: "launcher"
        function toggle() {
            shellContainer.panelManager.launcher.toggleState();
        }
    }
    
    IpcHandler {
        target: "clipboard"
        function toggle() {
            shellContainer.panelManager.clipboard.toggleState();
        }
    }
    
    IpcHandler {
        target: "notification"
        function toggle() {
            shellContainer.panelManager.notifications.toggleState();
        }
    }
}
