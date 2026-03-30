import QtQuick
import Quickshell
import Quickshell.Io
import "Panels"
import "Widgets"
import "Components"

ShellRoot {
    id: root

    ShellContainer {
        id: shellContainer
        anchors.fill: parent
    }
    
    TopBar {
        id: bar
        theme: shellContainer.theme
    }
    
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

    IpcHandler {
        target: "wallpaper"
        function toggle() {
            shellContainer.panelManager.wallpaper.toggleState();
        }
    }
}
