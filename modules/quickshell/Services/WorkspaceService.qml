import QtQuick
import Quickshell.Hyprland

QtObject {
    id: service

    property int activeWsId: Hyprland.focusedMonitor ? Hyprland.focusedMonitor.activeWorkspace.id : 1
    property int currentPage: Math.max(0, Math.floor((activeWsId - 1) / 5))
    property int startWs: (currentPage * 5) + 1
    
    property var occupiedWorkspaceIds: {
        let trigger = Hyprland.workspaces.values.length; 
        return Hyprland.workspaces.values.map(w => w.id);
    }

    function getWsId(index) {
        return startWs + index;
    }

    function switchWorkspace(wsId) {
        Hyprland.dispatch("workspace " + wsId);
    }
}