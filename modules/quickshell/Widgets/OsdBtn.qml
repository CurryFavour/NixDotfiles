import QtQuick

Rectangle {
    id: osdRoot
    
    property QtObject theme
    property string lbl: ""
    property color baseColor: theme.bgDim

    signal btnClicked()

    width: 42; height: 24
    color: baseColor
    border.color: theme.fg; border.width: 2; radius: 2

    // Bevels
    Rectangle {
        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
        anchors.margins: 2; height: 1; color: theme.highlight; opacity: osdMouse.pressed ? 0.0 : 0.6
    }
    Rectangle {
        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
        anchors.margins: 2; height: 2; color: theme.shadow; opacity: osdMouse.pressed ? 0.3 : 0.0
    }

    Text {
        text: osdRoot.lbl; anchors.centerIn: parent; color: theme.fg
        font.family: "sans-serif"; font.pixelSize: 11; font.weight: Font.Bold
    }

    MouseArea {
        id: osdMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
        onClicked: osdRoot.btnClicked()
    }
}
