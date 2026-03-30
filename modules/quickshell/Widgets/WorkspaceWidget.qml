import QtQuick
import "../Services"
import "../Widgets"

Row {
    id: wsRow
    
    property QtObject theme
    
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: 1
    anchors.leftMargin: 8
    spacing: 6

    WorkspaceService {
        id: wsLogic
    }

    Repeater {
        model: 5 
        delegate: RetroKey {
            theme: wsRow.theme
         
            property int wsId: wsLogic.getWsId(index)
            property bool isActiveWorkspace: wsLogic.activeWsId === wsId
            property bool isOccupied: wsLogic.occupiedWorkspaceIds.includes(wsId)
            
            text: wsId.toString()
            isActive: isActiveWorkspace               
            
            baseColor: isActiveWorkspace ? theme.yellow 
                     : isOccupied ? theme.blue 
                     : theme.bgDim
                     
            fgColor: (isActiveWorkspace || isOccupied) ? theme.fg 
                   : theme.fgMuted

            onClicked: wsLogic.switchWorkspace(wsId)
        }
    }
}
