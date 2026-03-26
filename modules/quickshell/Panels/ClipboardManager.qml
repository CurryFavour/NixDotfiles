import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland 
import "../Widgets" 

PanelWindow {
    id: clipWindow
    
    property QtObject theme
    visible: false
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    property var clipHistory: []
    property var filteredHistory: []
    property string activePreviewText: "[ NOTHIN SELECTED ]"

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
                updateFilter(searchInput.text);
            }
        }
    }

    Process { id: copyProcess }
    
    Process { 
        id: wipeProcess
        command: ["sh", "-c", "cliphist wipe"]
    }

    Timer {
        id: focusTimer
        interval: 50
        onTriggered: searchInput.forceActiveFocus()
    }

    function toggleState() {
        if (visible) {
            searchInput.focus = false;
            visible = false;
        } else {
            visible = true;
            getHistory.running = true;
            searchInput.text = ""; 
            activePreviewText = "[ WAITING FOR CLIPBOARD... ]";
            focusTimer.start(); 
        }
    }

    function updateFilter(query) {
        let q = query.trim().toLowerCase();
        filteredHistory = q === "" ? clipHistory : clipHistory.filter(item => item.text.toLowerCase().includes(q));
        
        if (filteredHistory.length > 0) {
            historyList.currentIndex = 0;
            activePreviewText = filteredHistory[0].text;
        } else {
            activePreviewText = "[ NO MATCHING DATA ]";
        }
    }

    function copyAndClose(rawItem) {
        let safeItem = rawItem.replace(/(["$`\\])/g, '\\$1');
        copyProcess.command = ["sh", "-c", `echo "${safeItem}" | cliphist decode | wl-copy`];
        copyProcess.running = true;
        toggleState();
    }
    
    function wipeHistory() {
        wipeProcess.running = true;
        clipHistory = [];
        updateFilter("");
    }

    MouseArea { anchors.fill: parent; onClicked: clipWindow.toggleState() }

    Rectangle {
        width: 420; height: 560
        anchors.centerIn: parent; anchors.verticalCenterOffset: 6; anchors.horizontalCenterOffset: 6
        color: theme.shadow; opacity: 0.3
    }

    Rectangle {
        id: popupBody
        width: 420; height: 560
        anchors.centerIn: parent
        color: theme.bgDim 
        border.color: theme.fg; border.width: 2

        MouseArea { anchors.fill: parent } 

        Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 2; height: 1; color: theme.highlight; opacity: 0.6 }
        Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.margins: 2; width: 1; color: theme.highlight; opacity: 0.6 }
        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 2; height: 1; color: theme.shadow; opacity: 0.15 }
        Rectangle { anchors.right: parent.right; anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.margins: 2; width: 1; color: theme.shadow; opacity: 0.15 }

        Rectangle {
            id: titleBar
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 4
            height: 24; color: theme.fg

            Text {
                text: "\\\\\\ CLIPBOARD"
                color: theme.bg
                font.family: "monospace"; font.pixelSize: 12; font.weight: Font.Bold
                anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 8
            }
            
            Rectangle {
                anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; anchors.rightMargin: 4
                width: 16; height: 16; color: theme.bgDim; border.color: theme.bg; border.width: 1
                Text { text: "x"; anchors.centerIn: parent; color: theme.fg; font.pixelSize: 10; font.weight: Font.Black; anchors.verticalCenterOffset: -1 }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: clipWindow.toggleState() }
            }
        }

        Row {
            id: titleStripe
            anchors.top: titleBar.bottom; anchors.left: parent.left; anchors.right: parent.right
            anchors.leftMargin: 4; anchors.rightMargin: 4; height: 4 
            Rectangle { width: parent.width / 5; height: parent.height; color: theme.green }
            Rectangle { width: parent.width / 5; height: parent.height; color: theme.blue }
            Rectangle { width: parent.width / 5; height: parent.height; color: theme.yellow }
            Rectangle { width: parent.width / 5; height: parent.height; color: theme.orange }
            Rectangle { width: parent.width / 5; height: parent.height; color: theme.red }
        }

        Rectangle {
            id: sWrap
            anchors.top: titleStripe.bottom; anchors.topMargin: 12
            anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 16
            height: 40; color: theme.clipboardBg; border.color: theme.fg; border.width: 2

            Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 2; height: 2; color: theme.shadow; opacity: 0.5 }
            
            Text {
                id: terminalPrompt
                text: ">"; color: theme.clipboardPrompt
                font.family: "monospace"; font.pixelSize: 16; font.weight: Font.Bold
                anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 12
            }

            TextInput {
                id: searchInput
                anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.left: terminalPrompt.right; anchors.right: parent.right
                anchors.leftMargin: 8; anchors.rightMargin: 12
                verticalAlignment: TextInput.AlignVCenter
                font.family: "monospace"; font.pixelSize: 15; font.weight: Font.Bold
                color: theme.clipboardText; clip: true
                
                onTextChanged: clipWindow.updateFilter(text)
                
                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (filteredHistory.length > 0) copyAndClose(filteredHistory[historyList.currentIndex].raw);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Escape) {
                        clipWindow.toggleState();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Up) {
                        historyList.decrementCurrentIndex();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Down) {
                        historyList.incrementCurrentIndex();
                        event.accepted = true;
                    }
                }
            }
        }

        Rectangle {
            id: listScreen
            anchors.top: sWrap.bottom; anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: previewScreen.top
            anchors.margins: 16; anchors.topMargin: 12; anchors.bottomMargin: 12
            color: theme.clipboardBg; border.color: theme.fg; border.width: 2

            ListView {
                id: historyList
                anchors.fill: parent; anchors.margins: 4; clip: true; spacing: 2
                model: clipWindow.filteredHistory
                
                onCurrentIndexChanged: {
                    if (currentIndex >= 0 && currentIndex < clipWindow.filteredHistory.length) {
                        clipWindow.activePreviewText = clipWindow.filteredHistory[currentIndex].text;
                    }
                }
                
                delegate: Rectangle {
                    width: ListView.view.width; height: 32
                    property bool isSelected: ListView.isCurrentItem || hoverArea.containsMouse
                    color: isSelected ? theme.blue : "transparent"
                    
                    Row {
                        anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8; spacing: 12
                        
                        Text {
                            text: modelData.id
                            anchors.verticalCenter: parent.verticalCenter; width: 36
                            color: isSelected ? "white" : theme.fgMuted
                            font.family: "monospace"; font.pixelSize: 11
                        }
                        Text {
                            text: modelData.text
                            anchors.verticalCenter: parent.verticalCenter; width: parent.width - 48
                            color: isSelected ? "white" : theme.clipboardText
                            font.family: "monospace"; font.pixelSize: 13; elide: Text.ElideRight; font.weight: isSelected ? Font.Bold : Font.Normal
                        }
                    }
                    
                    MouseArea {
                        id: hoverArea; anchors.fill: parent; hoverEnabled: true
                        onEntered: {
                            historyList.currentIndex = index; 
                        }
                        onClicked: copyAndClose(modelData.raw)
                    }
                }
            }
        }

        Rectangle {
            id: previewScreen
            anchors.bottom: hardwareBezel.top; anchors.left: parent.left; anchors.right: parent.right
            anchors.margins: 16; anchors.bottomMargin: 12
            height: 120
            color: theme.clipboardBg; border.color: theme.fg; border.width: 2

            Rectangle {
                anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 20
                color: theme.fg
                Text {
                    anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter
                    text: "PREVIEW"
                    color: theme.bg; font.family: "monospace"; font.pixelSize: 10; font.weight: Font.Bold
                }
            }

            Flickable {
                anchors.fill: parent; anchors.topMargin: 24; anchors.margins: 8
                clip: true; contentWidth: width; contentHeight: previewContent.height
                
                Text {
                    id: previewContent
                    width: parent.width
                    text: clipWindow.activePreviewText
                    color: theme.clipboardPrompt 
                    font.family: "monospace"; font.pixelSize: 12
                    wrapMode: Text.Wrap
                    lineHeight: 1.2
                }
            }
        }

        Rectangle {
            id: hardwareBezel
            anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 4
            height: 40; color: theme.bg; border.color: theme.fg; border.width: 2

            Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 2; height: 1; color: theme.highlight; opacity: 0.6 }
            
            Row {
                anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; anchors.rightMargin: 8; spacing: 8
                OsdBtn { theme: clipWindow.theme; lbl: "[ ^ ]"; onBtnClicked: { historyList.decrementCurrentIndex(); searchInput.forceActiveFocus(); } }
                OsdBtn { theme: clipWindow.theme; lbl: "[ v ]"; onBtnClicked: { historyList.incrementCurrentIndex(); searchInput.forceActiveFocus(); } }
                OsdBtn { theme: clipWindow.theme; lbl: "COPY"; baseColor: theme.green; onBtnClicked: { if (filteredHistory.length > 0) copyAndClose(filteredHistory[historyList.currentIndex].raw); } }
                OsdBtn { theme: clipWindow.theme; lbl: "WIPE"; baseColor: theme.red; onBtnClicked: { wipeHistory(); searchInput.forceActiveFocus(); } }
                OsdBtn { theme: clipWindow.theme; lbl: "ESC"; onBtnClicked: clipWindow.toggleState() }
            }
        }
    }
}
