import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../Widgets"
import "../Components"
import "../Services"

PanelWindow {
    id: bar
    property QtObject theme

    anchors { top: true; left: true; right: true }
    implicitHeight: 32
    color: theme.bg

    TitleStripe {
        id: topStripe
        theme: bar.theme
        anchors.top: parent.top
        width: parent.width
        height: 3
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 2
        color: theme.fg
    }

    WorkspaceWidget {
        theme: bar.theme
    }

    WindowTitleWidget {
        theme: bar.theme
    }

    Bluetooth {
        id: bluetoothService
    }

    Network {
        id: networkService
    }

    Bat {
        id: batService
    }

    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 1
        anchors.rightMargin: 8
        spacing: 6

        ToggleIndicatorWidget {
            id: wifiWidget
            theme: bar.theme
            isOn: networkService.isOn
            label: "WF"
            activeColor: theme.green
        }

        ToggleIndicatorWidget {
            id: btWidget
            theme: bar.theme
            isOn: bluetoothService.isOn
            label: "BT"
            activeColor: theme.blue
        }

        BatWidget {
            id: batWidget
            theme: bar.theme
        }

        ClockWidget {
            theme: bar.theme
        }
    }
}
