import QtQuick

Rectangle {
    id: previewScreen
    property QtObject theme
    property string previewText: "[ NOTHIN SELECTED ]"
    property string title: "PREVIEW"
    
    height: 120
    color: theme.clipboardBg; border.color: theme.fg; border.width: 2

    Rectangle {
        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 20
        color: theme.fg
        Text {
            anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter
            text: title
            color: theme.bg; font.family: "monospace"; font.pixelSize: 10; font.weight: Font.Bold
        }
    }

    Flickable {
        anchors.fill: parent; anchors.topMargin: 24; anchors.margins: 8
        clip: true; contentWidth: width; contentHeight: previewContent.height

        Text {
            id: previewContent
            width: parent.width
            text: previewText
            color: theme.clipboardPrompt
            font.family: "monospace"; font.pixelSize: 12
            wrapMode: Text.Wrap
            lineHeight: 1.2
        }
    }
}
