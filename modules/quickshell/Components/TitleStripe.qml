import QtQuick

Row {
    property QtObject theme
    height: 4

    Rectangle { width: parent.width / 5; height: parent.height; color: theme.green }
    Rectangle { width: parent.width / 5; height: parent.height; color: theme.blue }
    Rectangle { width: parent.width / 5; height: parent.height; color: theme.yellow }
    Rectangle { width: parent.width / 5; height: parent.height; color: theme.orange }
    Rectangle { width: parent.width / 5; height: parent.height; color: theme.red }
}
