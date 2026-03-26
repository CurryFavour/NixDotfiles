import QtQuick
import Quickshell.Hyprland
import "../Widgets"

Row {
    id: wsRow
    
    property QtObject theme
    
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: 1
    anchors.leftMargin: 8
    spacing: 6

    property int activeWsId: Hyprland.focusedMonitor ? Hyprland.focusedMonitor.activeWorkspace.id : 1
    property int currentPage: Math.max(0, Math.floor((activeWsId - 1) / 5))
    property int startWs: (currentPage * 5) + 1

    Repeater {
        model: 5 
        delegate: RetroKey {
            theme: wsRow.theme
         
            property int wsId: wsRow.startWs + index
            property int wsCountTracker: Hyprland.workspaces.values.length
            
            property bool isActiveWorkspace: wsId === wsRow.activeWsId
            property bool isOccupied: {
                let dummyTrigger = wsCountTracker; 
                return Hyprland.workspaces.values.some(w => w.id === wsId);
            }
            
            text: wsId.toString()
            baseColor: isActiveWorkspace ? theme.yellow : (isOccupied ? theme.blue : theme.bgDim)
            
            isActive: isActiveWorkspace               
            
            fgColor: (isActiveWorkspace || isOccupied) ? theme.fg : theme.fgMuted

            onClicked: Hyprland.dispatch("workspace " + wsId)
        }
    }
}
