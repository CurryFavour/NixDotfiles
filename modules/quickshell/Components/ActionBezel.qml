import QtQuick
import "../Widgets"

Rectangle {
    id: actionBezel
    property QtObject theme

    property var buttons: []

    height: 40
    color: theme.bg
    border.color: theme.fg
    border.width: 2

    BevelLine {
        theme: actionBezel.theme
        position: "top"
        opacity: 0.6
    }

    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 8
        spacing: 8

        Repeater {
            model: buttons
            delegate: OsdBtn {
                theme: actionBezel.theme
                lbl: modelData.label
                baseColor: modelData.baseColor || theme.bgDim
                onBtnClicked: {
                    actionBezel.actionTriggered(modelData.action)
                }
            }
        }
    }

    signal actionTriggered(string actionName)
}
