import QtQuick

Rectangle {
    id: searchInput
    property QtObject theme
    property string prompt: ">_"
    property color bgColor: theme.launcherBg
    property color promptColor: theme.launcherPrompt
    property color textColor: theme.launcherText
    signal filterChanged(string query)
    signal navigationRequested(string direction)
    signal executeRequested()
    signal escapeRequested()

    height: 40
    color: bgColor; border.color: theme.fg; border.width: 2

    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 2; height: 2; color: theme.shadow; opacity: 0.5 }
    
    Text {
        id: promptText
        text: prompt; color: promptColor
        font.family: "monospace"; font.pixelSize: 16; font.weight: Font.Bold
        anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 12
    }

    TextInput {
        id: input
        anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.left: promptText.right; anchors.right: parent.right
        anchors.leftMargin: 8; anchors.rightMargin: 12
        verticalAlignment: TextInput.AlignVCenter
        font.family: "monospace"; font.pixelSize: 15; font.weight: Font.Bold
        color: textColor; clip: true
        
        onTextChanged: filterChanged(text)
        
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                executeRequested();
                event.accepted = true;
            } else if (event.key === Qt.Key_Escape) {
                escapeRequested();
                event.accepted = true;
            } else if (event.key === Qt.Key_Up) {
                navigationRequested("up");
                event.accepted = true;
            } else if (event.key === Qt.Key_Down) {
                navigationRequested("down");
                event.accepted = true;
            }
        }
    }
    
    function clearText() {
        input.text = "";
        input.forceActiveFocus();
    }
    
    function forceFocus() {
        input.forceActiveFocus();
    }
}
