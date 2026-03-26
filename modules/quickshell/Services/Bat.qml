import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: batService
    
    property int batLevel: 100
    property bool isAc: false
    
    Process {
        id: batScript
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 'AC'"]
        stdout: StdioCollector {
            id: batStdout
            onStreamFinished: {
                let raw = batStdout.text.trim();
                if (raw === "AC" || raw === "") {
                    batService.isAc = true;
                    batService.batLevel = 100;
                    return;
                }
                batService.isAc = false;
                batService.batLevel = parseInt(raw);
            }
        }
    }
    
    Timer { 
        interval: 30000; running: true; repeat: true; 
        onTriggered: batScript.running = true; 
        Component.onCompleted: batScript.running = true 
    }
}
