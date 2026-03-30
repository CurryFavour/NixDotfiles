import QtQuick
import Quickshell
import Quickshell.Wayland
import "../Widgets"
import "."

PanelWindow {
    id: popupWindow

    property QtObject theme
    property alias titleBar: modularTitleBar
    property alias contentArea: contentContainer
    property alias bezel: actionBezel

    visible: false
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    signal opened()

    function toggleState() {
        visible = !visible
        if (visible) {
            opened()
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: popupWindow.toggleState()
    }

    Rectangle {
        width: popupBody.width
        height: popupBody.height
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 6
        anchors.horizontalCenterOffset: 6
        color: popupWindow.theme.shadow
        opacity: 0.3
    }

    Rectangle {
        id: popupBody
        width: popupWindow.implicitWidth
        height: popupWindow.implicitHeight
        anchors.centerIn: parent
        color: popupWindow.theme.bgDim
        border.color: popupWindow.theme.fg
        border.width: 2

        MouseArea {
            anchors.fill: parent
        }

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 2
            height: 1
            color: popupWindow.theme.highlight
            opacity: 0.6
        }
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 2
            width: 1
            color: popupWindow.theme.highlight
            opacity: 0.6
        }
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 2
            height: 1
            color: popupWindow.theme.shadow
            opacity: 0.15
        }
        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 2
            width: 1
            color: popupWindow.theme.shadow
            opacity: 0.15
        }

        ModularTitleBar {
            id: modularTitleBar
            theme: popupWindow.theme
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 4
            onCloseRequested: popupWindow.toggleState()
        }

        TitleStripe {
            id: titleStripe
            theme: popupWindow.theme
            anchors.top: modularTitleBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 4
            anchors.rightMargin: 4
        }

        Item {
            id: contentContainer
            anchors.top: titleStripe.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: actionBezel.top
            anchors.margins: 16
            anchors.topMargin: 12
            anchors.bottomMargin: 12
        }

        ActionBezel {
            id: actionBezel
            theme: popupWindow.theme
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 4
        }
    }
}
