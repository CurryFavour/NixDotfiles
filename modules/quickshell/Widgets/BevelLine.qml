import QtQuick

Rectangle {
    id: bevelLine

    property QtObject theme
    property string position: "top"
    property real intensity: 0.6

    color: theme.highlight
    height: 1

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 2

    states: [
        State {
            name: "top"
            AnchorChanges {
                target: bevelLine
                anchors.top: parent.top
            }
        },
        State {
            name: "bottom"
            AnchorChanges {
                target: bevelLine
                anchors.bottom: parent.bottom
            }
        }
    ]

    state: position
}
