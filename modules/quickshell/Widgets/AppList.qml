import QtQuick
import Quickshell

ListView {
    id: appList
    property QtObject theme
    property var apps: []
    
    model: apps
    clip: true
    spacing: 4
    
    delegate: Item {
        width: ListView.view.width; height: 38 
        property bool isSelected: hoverArea.containsMouse || ListView.isCurrentItem
        
        Rectangle {
            anchors.fill: parent
            color: isSelected ? theme.blue : "transparent"
            border.color: isSelected ? theme.fg : "transparent"
            border.width: isSelected ? 2 : 0
            
            Rectangle {
                visible: isSelected
                anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 2
                height: 1; color: theme.highlight; opacity: 0.25
            }

            Row {
                anchors.fill: parent; anchors.leftMargin: 12; spacing: 12
                Image { source: Quickshell.iconPath(modelData.icon, true); width: 22; height: 22; anchors.verticalCenter: parent.verticalCenter }
                Text { text: modelData.name; color: isSelected ? theme.bg : theme.fg; font.family: "sans-serif"; font.pixelSize: 14; font.weight: Font.Bold; anchors.verticalCenter: parent.verticalCenter }
            }
        }
        MouseArea { 
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true
            onEntered: appList.currentIndex = index
            onClicked: {
                appList.appSelected(index);
            }
        }
    }
    
    signal appSelected(int index)
}
