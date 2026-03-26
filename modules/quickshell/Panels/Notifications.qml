import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland 
import Quickshell.Services.Notifications 

PanelWindow {
    id: printerWindow
    
    screen: Quickshell.screens[0] 
    
    property QtObject theme
    
    visible: false
    WlrLayershell.layer: WlrLayer.Overlay
    
    WlrLayershell.keyboardFocus: printerWindow.visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    property bool isPrinting: false
    property real currentPaperHeight: 0
    property real maxPaperHeight: 460 
    
    property int visibleCount: 2

    property var allNotifications: []
    property var currentNotifications: []

    Timer {
        id: autoCloseTimer
        onTriggered: printerWindow.hidePopup()
    }

    NotificationServer {
        id: server
        
        onNotification: (notification) => {
            let appName = (notification.appName || "SYSTEM").toUpperCase().substring(0, 12);
            let urgencyLevel = notification.urgency !== undefined ? notification.urgency : 1;
            
            let newNotif = {
                id: notification.id, 
                app: appName,
                title: notification.summary || "Alert",
                body: (notification.body || "").replace(/<[^>]*>?/gm, ''),
                urgency: urgencyLevel
            };

            let arr = printerWindow.allNotifications.slice();
            let existingIdx = arr.findIndex(n => n.id === notification.id);
            let isNewNotification = (existingIdx === -1);
            
            if (!isNewNotification) {
                arr[existingIdx] = newNotif;
            } else {
                arr.push(newNotif);
                if (arr.length > 50) arr.shift();
            }
            
            printerWindow.allNotifications = arr;

            if (isNewNotification) {
                if (printerWindow.visible) {
                    printerWindow.visibleCount = Math.min(printerWindow.visibleCount + 1, 5);
                } else {
                    printerWindow.visibleCount = 1;
                }
            }
            
            printerWindow.updateModel();
            
            let timeoutMs = (notification.expireTimeout !== undefined && notification.expireTimeout > 0) 
                            ? notification.expireTimeout * 1000 : 5000;
                            
            printerWindow.showPopup(timeoutMs);
        }
    }

    function updateModel() {
        let startIndex = Math.max(0, allNotifications.length - visibleCount);
        currentNotifications = allNotifications.slice(startIndex);
    }

    Timer {
        id: focusTimer
        interval: 50
        onTriggered: paperList.forceActiveFocus()
    }

    Timer {
        id: printTimer
        interval: 35 
        repeat: true
        onTriggered: {
            if (isPrinting) {
                let targetHeight = printerWindow.allNotifications.length === 0 ?
                    80 : Math.min(maxPaperHeight, paperList.contentHeight + 8);
                
                if (currentPaperHeight < targetHeight) {
                    currentPaperHeight += 18;
                    if (currentPaperHeight >= targetHeight) {
                        currentPaperHeight = targetHeight;
                        running = false; 
                    }
                } else if (currentPaperHeight > targetHeight) {
                    currentPaperHeight = targetHeight;
                    running = false;
                } else {
                    running = false;
                }
            } else {
                currentPaperHeight -= 56;
                if (currentPaperHeight <= 0) {
                    currentPaperHeight = 0;
                    running = false;
                    printerWindow.visible = false; 
                }
            }
        }
    }

    function showPopup(timeoutMs) {
        if (!visible) {
            visible = true;
            isPrinting = true;
            currentPaperHeight = 0;
            printTimer.start();
        } else if (!isPrinting) {
            isPrinting = true;
            printTimer.start();
        }
        
        autoCloseTimer.interval = timeoutMs;
        autoCloseTimer.restart();
    }

    function hidePopup() {
        if (visible && isPrinting) {
            isPrinting = false;
            printTimer.start();
        }
    }

    function toggleState() {
        if (visible) {
            hidePopup();
        } else {
            visibleCount = Math.max(2, Math.min(allNotifications.length, 5)); 
            updateModel();
            autoCloseTimer.stop(); 
            
            visible = true;
            isPrinting = true;
            currentPaperHeight = 0;
            
            if (currentNotifications.length > 0) {
                paperList.currentIndex = currentNotifications.length - 1;
            }
            
            printTimer.start();
            focusTimer.start();
        }
    }

    MouseArea { 
        anchors.fill: parent
        enabled: printerWindow.visible 
        onClicked: printerWindow.hidePopup() 
    }

    Rectangle {
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.horizontalCenter: parent.horizontalCenter
        width: 360; height: 4; color: theme.shadow; opacity: 0.8; radius: 2
    }

    Item {
        id: printSlot
        anchors.top: parent.top
        anchors.topMargin: 2 
        anchors.horizontalCenter: parent.horizontalCenter
        width: 340 
        clip: true 
        height: currentPaperHeight 

        HoverHandler {
            id: printerHover
        }

        Rectangle {
            id: paperBg
            anchors.fill: parent 
            color: theme.bgDim 
            
            Rectangle { anchors.left: parent.left; width: 1; height: parent.height; color: theme.fgMuted }
            Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: theme.fgMuted }

            Column {
                anchors.left: parent.left; anchors.leftMargin: 4; anchors.top: parent.top; anchors.bottom: parent.bottom
                anchors.topMargin: 4; anchors.bottomMargin: 4; spacing: 12; clip: true
                Repeater { model: Math.ceil(maxPaperHeight / 18); Rectangle { width: 6; height: 6; radius: 3; color: "transparent"; border.color: theme.fgMuted } }
            }
            Column {
                anchors.right: parent.right; anchors.rightMargin: 4; anchors.top: parent.top; anchors.bottom: parent.bottom
                anchors.topMargin: 4; anchors.bottomMargin: 4; spacing: 12; clip: true
                Repeater { model: Math.ceil(maxPaperHeight / 18); Rectangle { width: 6; height: 6; radius: 3; color: "transparent"; border.color: theme.fgMuted } }
            }
            
            Text {
                anchors.centerIn: parent
                visible: printerWindow.allNotifications.length === 0
                text: "*** NO NEW LOGS ***"
                color: theme.fg
                font.family: "monospace"
                font.pixelSize: 12
                font.weight: Font.Bold
            }

            ListView {
                id: paperList
                anchors.fill: parent
                anchors.bottomMargin: 8 
                anchors.leftMargin: 18; anchors.rightMargin: 18
                clip: true
                spacing: 8
                
                visible: printerWindow.allNotifications.length > 0
                model: printerWindow.currentNotifications
                boundsBehavior: Flickable.StopAtBounds

                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape) { 
                        printerWindow.toggleState();
                        event.accepted = true; 
                    }
                    else if (event.key === Qt.Key_Up) { 
                        if (currentIndex === 0 && printerWindow.visibleCount < printerWindow.allNotifications.length) {
                            let remaining = printerWindow.allNotifications.length - printerWindow.visibleCount;
                            let toAdd = Math.min(2, remaining);
                            
                            printerWindow.visibleCount += toAdd;
                            printerWindow.updateModel();
                            
                            paperList.currentIndex = (toAdd - 1); 
                            printTimer.start();
                        } else {
                            decrementCurrentIndex();
                        }
                        event.accepted = true;
                    } 
                    else if (event.key === Qt.Key_Down) { 
                        incrementCurrentIndex();
                        event.accepted = true; 
                    }
                    else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Delete) { 
                        printerWindow.toggleState();
                        event.accepted = true; 
                    }
                }

                header: Item {
                    width: ListView.view.width
                    property bool isTopReached: printerWindow.visibleCount >= printerWindow.allNotifications.length
                    height: isTopReached ? 80 : 0
                    clip: true
                    
                    Text {
                        anchors.centerIn: parent
                        visible: parent.isTopReached
                        text: "*** SYSTEM LOG_PRINT ***\n" + Qt.formatDateTime(new Date(), "yyyy-MM-dd hh:mm")
                        color: theme.fg 
                        font.family: "monospace"
                        font.pixelSize: 10; font.weight: Font.Bold; horizontalAlignment: Text.AlignHCenter
                    }
                    Rectangle { 
                        visible: parent.isTopReached
                        anchors.bottom: parent.bottom; anchors.bottomMargin: 8; 
                        anchors.horizontalCenter: parent.horizontalCenter; 
                        width: parent.width - 36; height: 1; color: theme.fg; opacity: 0.3; border.width: 1; border.color: theme.fg 
                    }
                }

                delegate: Rectangle {
                    id: delegateRoot
                    width: ListView.view.width
                    height: delegateCol.height + 16
                    radius: 2
                    
                    property bool isSelected: ListView.isCurrentItem || hoverArea.containsMouse
                    color: isSelected ? theme.fg : "transparent" 

                    function getTextColor() {
                        if (isSelected) return theme.bgDim; 
                        if (modelData.urgency === 2) return theme.red; 
                        if (modelData.urgency === 0) return theme.fgMuted; 
                        return theme.fg; 
                    }

                    Column {
                        id: delegateCol
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left; anchors.right: parent.right
                        anchors.margins: 10
                        spacing: 4
                        
                        Text { 
                            text: "[" + modelData.app + "] " + modelData.title 
                            color: delegateRoot.getTextColor()
                            font.family: "monospace"
                            font.pixelSize: 11; font.weight: Font.Bold; wrapMode: Text.Wrap; width: parent.width 
                        }
                        Text { 
                            text: modelData.body 
                            color: delegateRoot.getTextColor()
                            font.family: "monospace"
                            font.pixelSize: 11; wrapMode: Text.Wrap; width: parent.width; 
                            opacity: delegateRoot.isSelected ? 1.0 : (modelData.urgency === 2 ? 1.0 : 0.8)
                        }
                    }

                    MouseArea {
                        id: hoverArea; anchors.fill: parent; hoverEnabled: true
                        onEntered: paperList.currentIndex = index
                        onClicked: printerWindow.toggleState()
                    }
                }
                 
                footer: Item {
                    width: ListView.view.width; height: 60
                    Text { anchors.centerIn: parent; text: "--- END OF LOG ---"; color: theme.fg; font.family: "monospace"; font.pixelSize: 10; font.weight: Font.Bold }
                }
            }

            Row {
                anchors.bottom: parent.bottom; anchors.bottomMargin: -4; width: parent.width; clip: true
                Repeater {
                    model: Math.ceil(parent.width / 8)
                    Rectangle { width: 8; height: 8; radius: 4; rotation: 45; color: "transparent"; border.color: theme.fgMuted; border.width: 1 }
                }
            }
        }
    }
}
