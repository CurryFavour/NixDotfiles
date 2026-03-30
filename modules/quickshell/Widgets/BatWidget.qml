import QtQuick
import Quickshell

Rectangle {
    id: batWidget
    width: 76
    height: 26
    anchors.verticalCenter: parent.verticalCenter
    
    property QtObject theme
    property int batLevel: batService.batLevel
    property bool isAc: batService.isAc
    property color activeColor: isAc ? theme.blue : (batLevel <= 20 ? theme.red : (batLevel <= 50 ? theme.yellow : theme.green))
    
    color: theme.bgDim 
    border.color: theme.fg
    border.width: 2
    radius: 3

    Rectangle { 
        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
        anchors.margins: 2; height: 1; color: theme.highlight; opacity: 0.5 
    }

    Item {
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        width: 24
        height: 12

        Rectangle {
            anchors.left: batBody.right
            anchors.leftMargin: -1
            anchors.verticalCenter: parent.verticalCenter
            width: 4
            height: 6
            color: theme.topbarWidgetBg
            border.color: theme.fg
            border.width: 1
            z: 1
        }

        Rectangle {
            id: batBody
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 21
            height: parent.height
            color: theme.topbarWidgetBg
            border.color: theme.fg
            border.width: 1
            radius: 1
            clip: true
            z: 2

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 1
                
                width: batWidget.isAc ? parent.width - 2 : Math.max(0, (parent.width - 2) * (batWidget.batLevel / 100))
                color: batWidget.activeColor
                
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: parent.height / 2
                    color: theme.topbarWidgetBg
                    opacity: 0.25
                }
            }
        }
    }

    Text {
        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        text: batWidget.isAc ? "AC" : batWidget.batLevel + "%"
        color: batWidget.activeColor
        font.family: "sans-serif"
        font.pixelSize: 11
        font.weight: Font.Bold
    }
}
