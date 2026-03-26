import QtQuick

Rectangle {
    id: btWidget
    
    property QtObject theme
    property bool isOn: false
    
    width: 34
    height: 26 
    
    color: theme.bgDim 
    border.color: theme.fg
    border.width: 2
    radius: 3

    Rectangle { 
        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
        anchors.margins: 2; height: 1; color: theme.highlight; opacity: 0.5 
    }

    Item {
        anchors.centerIn: parent
        width: 28
        height: 20

        Rectangle {
            x: 2
            y: 2
            width: 24
            height: 18
            color: theme.fg
            radius: 2
        }

        Rectangle {
            width: 24
            height: 18
            
            x: btWidget.isOn ? 2 : 0
            y: btWidget.isOn ? 2 : 0
            
            color: theme.bg 
            border.color: theme.fg
            border.width: 1
            radius: 2

            Text {
                anchors.top: parent.top
                anchors.topMargin: 2
                anchors.horizontalCenter: parent.horizontalCenter
                text: "BT"
                color: theme.fg
                font.family: "sans-serif"
                font.pixelSize: 7
                font.weight: Font.Bold
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 3
                anchors.horizontalCenter: parent.horizontalCenter
                width: 14
                height: 3
                radius: 1
                
                color: btWidget.isOn ? theme.blue : theme.shadow
                border.color: theme.fg
                border.width: 1
                
                Rectangle {
                    anchors.fill: parent; anchors.margins: 0.5
                    color: theme.fg
                    opacity: btWidget.isOn ? 0.4 : 0.0
                    radius: 1
                }
            }

            Behavior on x { NumberAnimation { duration: 75; easing.type: Easing.OutQuad } }
            Behavior on y { NumberAnimation { duration: 75; easing.type: Easing.OutQuad } }
        }
    }
}
