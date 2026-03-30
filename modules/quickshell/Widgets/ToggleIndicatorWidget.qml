import QtQuick
import "../Widgets"

Rectangle {
    id: indicatorWidget

    property QtObject theme
    property bool isOn: false
    property string label: ""
    property color activeColor: theme.green

    width: 34
    height: 26

    color: theme.bgDim
    border.color: theme.fg
    border.width: 2
    radius: 3

    BevelLine {
        theme: indicatorWidget.theme
        position: "top"
        opacity: 0.5
    }

    Item {
        anchors.centerIn: parent
        width: 28
        height: 22

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

            x: indicatorWidget.isOn ? 2 : 0
            y: indicatorWidget.isOn ? 2 : 0

            color: theme.bg
            border.color: theme.fg
            border.width: 1
            radius: 2

            Text {
                anchors.top: parent.top
                anchors.topMargin: 2
                anchors.horizontalCenter: parent.horizontalCenter
                text: indicatorWidget.label
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

                color: indicatorWidget.isOn ? indicatorWidget.activeColor : theme.shadow
                border.color: theme.fg
                border.width: 1

                Rectangle {
                    anchors.fill: parent; anchors.margins: 0.5
                    color: theme.fg
                    opacity: indicatorWidget.isOn ? 0.4 : 0.0
                    radius: 1
                }
            }

            Behavior on x { NumberAnimation { duration: 75; easing.type: Easing.OutQuad } }
            Behavior on y { NumberAnimation { duration: 75; easing.type: Easing.OutQuad } }
        }
    }
}
