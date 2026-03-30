import QtQuick
import Quickshell.Hyprland

QtObject {
    id: service

    // Core state tracking
    property int activeWsId: Hyprland.focusedMonitor ? Hyprland.focusedMonitor.activeWorkspace.id : 1
    property int currentPage: Math.max(0, Math.floor((activeWsId - 1) / 5))
    property int startWs: (currentPage * 5) + 1
    
    // Reactive array of occupied IDs.
    // By referencing .length, QML knows to rebuild this array whenever a workspace opens/closes.
    property var occupiedWorkspaceIds: {
        let trigger = Hyprland.workspaces.values.length; 
        return Hyprland.workspaces.values.map(w => w.id);
    }

    // Pure calculation
    function getWsId(index) {
        return startWs + index;
    }

    // Action
    function switchWorkspace(wsId) {
        Hyprland.dispatch("workspace " + wsId);
    }
}