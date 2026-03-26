import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland 
import "../Widgets"
import "../Services" 

PanelWindow {
    id: bar
    property QtObject theme

    anchors { top: true; left: true; right: true }
    implicitHeight: 32 
    color: theme.bg

    Row {
        anchors.top: parent.top
        width: parent.width
        height: 3 
        Rectangle { width: parent.width / 5; height: parent.height; color: theme.green }
        Rectangle { width: parent.width / 5; height: parent.height; color: theme.blue }
        Rectangle { width: parent.width / 5; height: parent.height; color: theme.yellow }
        Rectangle { width: parent.width / 5; height: parent.height; color: theme.orange }
        Rectangle { width: parent.width / 5; height: parent.height; color: theme.red }
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
        anchors.right: parent.right;
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 1;
        anchors.rightMargin: 8
        spacing: 6 

        WifiWidget {
            id: wifiWidget
            theme: bar.theme
            isOn: networkService.isOn
        }

        BluetoothWidget {
            id: btWidget
            theme: bar.theme
            isOn: bluetoothService.isOn
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
