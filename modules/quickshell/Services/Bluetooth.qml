import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: bluetoothService
    
    property bool isOn: false
    
    Process {
        id: btScript
        command: ["sh", "-c", "bluetoothctl devices Connected 2>/dev/null | grep -q 'Device' && echo 'ON' || echo 'OFF'"]
        stdout: StdioCollector {
            id: btStdout
            onStreamFinished: {
                bluetoothService.isOn = (btStdout.text.trim() === "ON");
            }
        }
    }
    
    Timer { 
        interval: 5000; 
        running: true; 
        repeat: true; 
        onTriggered: btScript.running = true; 
        Component.onCompleted: btScript.running = true 
    }
}
