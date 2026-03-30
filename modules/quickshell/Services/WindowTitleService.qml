import QtQuick
import Quickshell.Hyprland

QtObject {
    id: service

    property var activeToplevel: Hyprland.activeToplevel
    property var focusedWorkspace: Hyprland.focusedWorkspace
    property var focusedMonitor: Hyprland.focusedMonitor

    property bool isValidWindow: {
        if (!activeToplevel || !focusedWorkspace) return false;
        if (!activeToplevel.workspace) return false;
        return activeToplevel.workspace.id === focusedWorkspace.id;
    }

    property string rawTitle: isValidWindow ? activeToplevel.title : ""
    property string safeTitle: rawTitle.trim()
    property bool isEmpty: safeTitle === ""

    property int currentWs: focusedMonitor ? focusedMonitor.activeWorkspace.id : 1

    readonly property string standardIdleText: "[ IDLIN ]"
    readonly property string asideIdleText: "A-SIDE: [ SYSTEM_IDLE ]"

    property string resolvedTitle: isEmpty ? standardIdleText : safeTitle
}