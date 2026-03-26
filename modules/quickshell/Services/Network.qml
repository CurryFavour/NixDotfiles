import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: networkService
    
    property bool isOn: false
    
    Process {
        id: wifiScript
        command: ["sh", "-c", "cat /sys/class/net/wl*/operstate 2>/dev/null | grep -q 'up' && echo 'ON' || echo 'OFF'"]
        stdout: StdioCollector {
            id: wifiStdout
            onStreamFinished: {
                networkService.isOn = (wifiStdout.text.trim() === "ON");
            }
        }
    }
    
    Timer { 
        interval: 5000; 
        running: true; 
        repeat: true; 
        onTriggered: wifiScript.running = true; 
        Component.onCompleted: wifiScript.running = true 
    }
}
