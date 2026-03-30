import QtQuick
import Quickshell.Io

Item {
    id: clipboardService
    
    property var clipHistory: []
    property var filteredHistory: []
    
    signal historyUpdated(var history)
    signal filterUpdated(var filteredHistory)
    signal previewUpdated(string previewText)
    
    Process {
        id: getHistory
        command: ["sh", "-c", "cliphist list"]
        stdout: StdioCollector {
            id: clipStdout
            onStreamFinished: {
                let raw = clipStdout.text || ""; 
                let lines = raw.trim().split("\n").filter(l => l !== "");
                
                let parsed = lines.map(l => {
                    let idx = l.indexOf('\t');
                    if(idx === -1) return { raw: l, id: "---", text: l };
                    return { 
                        raw: l, 
                        id: l.substring(0, idx), 
                        text: l.substring(idx + 1) 
                    };
                });
                
                clipHistory = parsed;
                historyUpdated(clipHistory);
                updateFilter("");
            }
        }
    }
    
    Process { id: copyProcess }
    
    Process { 
        id: wipeProcess
        command: ["sh", "-c", "cliphist wipe"]
    }
    
    function loadHistory() {
        getHistory.running = true;
    }
    
    function updateFilter(query) {
        let q = query.trim().toLowerCase();
        filteredHistory = q === "" ? clipHistory : clipHistory.filter(item => item.text.toLowerCase().includes(q));
        filterUpdated(filteredHistory);
        
        if (filteredHistory.length > 0) {
            previewUpdated(filteredHistory[0].text);
        } else {
            previewUpdated("[ NO MATCHING DATA ]");
        }
    }
    
    function copyItem(rawItem) {
        let safeItem = rawItem.replace(/(["$`\\])/g, '\\$1');
        copyProcess.command = ["sh", "-c", `echo "${safeItem}" | cliphist decode | wl-copy`];
        copyProcess.running = true;
    }
    
    function wipeHistory() {
        wipeProcess.running = true;
        clipHistory = [];
        updateFilter("");
    }
}
