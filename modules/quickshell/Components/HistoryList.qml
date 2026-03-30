import QtQuick

ListView {
    id: historyList
    property QtObject theme
    property var items: []
    property bool showIds: true

    model: items
    clip: true
    spacing: 2

    signal itemSelected(int index, var item)

    onCurrentIndexChanged: {
        if (currentIndex >= 0 && currentIndex < items.length) {
            previewRequested(items[currentIndex].text);
        }
    }

    signal previewRequested(string text)

    delegate: Rectangle {
        width: ListView.view.width; height: 32
        property bool isSelected: ListView.isCurrentItem || hoverArea.containsMouse
        color: isSelected ? historyList.theme.blue : "transparent"

        Row {
            anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8; spacing: 12

            Text {
                visible: showIds
                text: modelData.id
                anchors.verticalCenter: parent.verticalCenter; width: 36
                color: isSelected ? "white" : historyList.theme.fgMuted
                font.family: "monospace"; font.pixelSize: 11
            }
            Text {
                text: modelData.text
                anchors.verticalCenter: parent.verticalCenter;
                width: showIds ? parent.width - 48 : parent.width - 16
                color: isSelected ? "white" : historyList.theme.clipboardText
                font.family: "monospace"; font.pixelSize: 13;
                elide: Text.ElideRight;
                font.weight: isSelected ? Font.Bold : Font.Normal
            }
        }

        MouseArea {
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                historyList.currentIndex = index;
            }
            onClicked: itemSelected(index, modelData)
        }
    }
}
