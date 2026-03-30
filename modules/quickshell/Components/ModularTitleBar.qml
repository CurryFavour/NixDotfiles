import QtQuick

Rectangle {
    id: titleBar
    property QtObject theme
    property string title: "\\\\\\ LAUNCHER"
    signal closeRequested()
    
    height: 24
    color: theme.fg

    Text {
        text: title
        color: theme.bg
        font.family: "monospace"; font.pixelSize: 12; font.weight: Font.Bold
        anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 8
    }

    Rectangle {
        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; anchors.rightMargin: 4
        width: 16; height: 16;
        color: theme.bgDim; border.color: theme.bg; border.width: 1
        Text {
            text: "x";
            anchors.centerIn: parent;
            color: theme.fg
            font.pixelSize: 10; font.weight: Font.Black; anchors.verticalCenterOffset: -1
        }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: closeRequested() }
    }
}
