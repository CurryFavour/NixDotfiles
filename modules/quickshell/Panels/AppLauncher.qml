import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland 
import "../Widgets" 

PanelWindow {
    id: launcherWindow
    
    property QtObject theme
    
    visible: false
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    function toggleState() {
        visible = !visible;
        if (visible) { searchInput.text = ""; searchInput.forceActiveFocus(); }
    }

    MouseArea { anchors.fill: parent; onClicked: launcherWindow.toggleState() }

    property var allApps: [...DesktopEntries.applications.values].sort((a, b) => a.name.localeCompare(b.name))
    property var filteredApps: allApps

    function updateFilter(query) {
        let q = query.trim().toLowerCase();
        filteredApps = q === "" ? allApps : allApps.filter(app => app.name && app.name.toLowerCase().includes(q));
        appList.currentIndex = 0;
    }

    Rectangle {
        width: 380; height: 460
        anchors.centerIn: parent; anchors.verticalCenterOffset: 6; anchors.horizontalCenterOffset: 6
        color: theme.shadow; opacity: 0.3
    }

    Rectangle {
        id: popupBody
        width: 380; height: 460
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
                text: "\\\\\\ LAUNCHER"
                color: theme.bg
                font.family: "monospace"; font.pixelSize: 12; font.weight: Font.Bold
                anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 8
            }
            
            Rectangle {
                anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; anchors.rightMargin: 4
                width: 16; height: 16; color: theme.bgDim; border.color: theme.bg; border.width: 1
                Text { text: "x"; anchors.centerIn: parent; color: theme.fg; font.pixelSize: 10; font.weight: Font.Black; anchors.verticalCenterOffset: -1 }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: launcherWindow.toggleState() }
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
            height: 40; color: theme.launcherBg; border.color: theme.fg; border.width: 2

            Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 2; height: 2; color: theme.shadow; opacity: 0.5 }
            
            Text {
                text: ">_"; color: theme.launcherPrompt
                font.family: "monospace"; font.pixelSize: 16; font.weight: Font.Bold
                anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 12
            }

            TextInput {
                id: searchInput
                anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                anchors.leftMargin: 40; anchors.rightMargin: 12
                verticalAlignment: TextInput.AlignVCenter
                font.family: "monospace"; font.pixelSize: 15; font.weight: Font.Bold
                color: theme.launcherText; clip: true
                
                onTextChanged: launcherWindow.updateFilter(text)
                
                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (launcherWindow.filteredApps.length > 0) launcherWindow.filteredApps[appList.currentIndex].execute();
                        launcherWindow.toggleState();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Escape) {
                        launcherWindow.toggleState();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Up) {
                        appList.decrementCurrentIndex();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Down) {
                        appList.incrementCurrentIndex();
                        event.accepted = true;
                    }
                }
            }
        }

        ListView {
            id: appList
            anchors.top: sWrap.bottom; anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: hardwareBezel.top
            anchors.margins: 16; anchors.topMargin: 12; anchors.bottomMargin: 12
            model: launcherWindow.filteredApps; clip: true; spacing: 4
            
            delegate: Item {
                width: ListView.view.width; height: 38 
                property bool isSelected: hoverArea.containsMouse || ListView.isCurrentItem
                
                Rectangle {
                    anchors.fill: parent
                    color: isSelected ? theme.blue : "transparent"
                    border.color: isSelected ? theme.fg : "transparent"
                    border.width: isSelected ? 2 : 0
                    
                    Rectangle {
                        visible: isSelected
                        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 2
                        height: 1; color: theme.highlight; opacity: 0.25
                    }

                    Row {
                        anchors.fill: parent; anchors.leftMargin: 12; spacing: 12
                        Image { source: Quickshell.iconPath(modelData.icon, true); width: 22; height: 22; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: modelData.name; color: isSelected ? "white" : "black"; font.family: "sans-serif"; font.pixelSize: 14; font.weight: Font.Bold; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
                MouseArea { id: hoverArea; anchors.fill: parent; hoverEnabled: true; onEntered: appList.currentIndex = index; onClicked: { modelData.execute(); launcherWindow.toggleState(); } }
            }
        }

        Rectangle {
            id: hardwareBezel
            anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 4
            height: 40; color: theme.bg; border.color: theme.fg; border.width: 2

            Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 2; height: 1; color: theme.highlight; opacity: 0.6 }
            
            Row {
                anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; anchors.rightMargin: 8; spacing: 8
                OsdBtn { theme: launcherWindow.theme; lbl: "[ ^ ]"; onBtnClicked: { appList.decrementCurrentIndex(); searchInput.forceActiveFocus(); } }
                OsdBtn { theme: launcherWindow.theme; lbl: "[ v ]"; onBtnClicked: { appList.incrementCurrentIndex(); searchInput.forceActiveFocus(); } }
                OsdBtn { theme: launcherWindow.theme; lbl: "RUN"; baseColor: theme.green; onBtnClicked: { if (launcherWindow.filteredApps.length > 0) launcherWindow.filteredApps[appList.currentIndex].execute(); launcherWindow.toggleState(); } }
                OsdBtn { theme: launcherWindow.theme; lbl: "ESC"; onBtnClicked: launcherWindow.toggleState() }
            }
        }
    }
}
