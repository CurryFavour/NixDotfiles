import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland 
import Quickshell.Services.Notifications 

PanelWindow {
    id: printerWindow
    
    screen: Quickshell.screens[0] 
    property QtObject theme
    
    visible: windowHeight > 0 || currentPaperHeight > 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: printerWindow.visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    
    anchors { top: true }
    
    implicitWidth: 360
    implicitHeight: windowHeight + 40 
    exclusiveZone: 0
    color: "transparent"

    property bool isOpen: false
    property real targetPaperHeight: 0
    property real currentPaperHeight: 0
    property real windowHeight: 0 
    property real maxPaperHeight: 460 
    
    property int visibleCount: 2
    property var allNotifications: []
    property var currentNotifications: []

    NumberAnimation {
        id: openAnim
        target: printerWindow
        property: "currentPaperHeight"
        duration: 350
        easing.type: Easing.OutCubic
        onFinished: {
            if (isOpen) windowHeight = targetPaperHeight; 
        }
    }

    SequentialAnimation {
        id: closeAnim
        NumberAnimation {
            target: printerWindow
            property: "currentPaperHeight"
            to: 0
            duration: 300
            easing.type: Easing.InCubic
        }
        ScriptAction {
            script: {
                windowHeight = 0; 
            }
        }
    }

    function updateHeight() {
        if (isOpen) {
            let baseHeight = allNotifications.length === 0 ? 80 : paperList.contentHeight + 30;
            targetPaperHeight = Math.min(maxPaperHeight, baseHeight);
            
            closeAnim.stop();
            
            if (targetPaperHeight > windowHeight) {
                windowHeight = targetPaperHeight; 
            }
            
            openAnim.to = targetPaperHeight;
            openAnim.restart();
        } else {
            openAnim.stop();
            closeAnim.restart();
        }
    }

    Connections {
        target: paperList
        function onContentHeightChanged() {
            if (isOpen) updateHeight();
        }
    }

    Timer {
        id: autoCloseTimer
        onTriggered: hidePopup()
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
                printerWindow.visibleCount = isOpen ? Math.min(printerWindow.visibleCount + 1, 5) : 1;
            }
            
            printerWindow.updateModel();
            
            let timeoutMs = (notification.expireTimeout !== undefined && notification.expireTimeout > 0) 
                            ? notification.expireTimeout * 1000 : 5000;
                            
            showPopup(timeoutMs);
        }
    }

    function updateModel() {
        let startIndex = Math.max(0, allNotifications.length - visibleCount);
        currentNotifications = allNotifications.slice(startIndex);
        Qt.callLater(updateHeight); 
    }

    Timer {
        id: focusTimer
        interval: 50
        onTriggered: paperList.forceActiveFocus()
    }

    function showPopup(timeoutMs) {
        isOpen = true;
        updateHeight();
        autoCloseTimer.interval = timeoutMs;
        autoCloseTimer.restart();
    }

    function hidePopup() {
        isOpen = false;
        updateHeight();
    }

    function toggleState() {
        if (isOpen) {
            hidePopup();
        } else {
            visibleCount = Math.max(2, Math.min(allNotifications.length, 5)); 
            updateModel();
            autoCloseTimer.stop(); 
            
            isOpen = true;
            updateHeight();
            
            if (currentNotifications.length > 0) {
                paperList.currentIndex = currentNotifications.length - 1;
            }
            
            focusTimer.start();
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: printerWindow.visible
        onClicked: hidePopup()
    }

    Rectangle {
        id: hardwareSlot
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: 360; height: 6
        color: "#111" 
        radius: 2
        border.color: theme.shadow || "#333"; border.width: 1
        z: 2 
    }

    Item {
        id: printSlot
        anchors.top: hardwareSlot.bottom
        anchors.topMargin: -2 
        anchors.horizontalCenter: parent.horizontalCenter
        width: 360 
        clip: true
        height: currentPaperHeight > 0 ? currentPaperHeight + 26 : 0

        HoverHandler {
            id: printerHover
        }

        // --- 1. SOLID DROP SHADOW ---
        Item {
            id: shadowWrapper
            height: targetPaperHeight > 0 ? targetPaperHeight + 6 : currentPaperHeight + 10 
            width: 340
            x: 14
            anchors.top: parent.top
            anchors.topMargin: 0 // Pushes the shadow 6px below the paper
            visible: currentPaperHeight > 0
            
            // Solid rectangular shadow block[cite: 2]
            Rectangle {
                anchors.fill: parent
                color: theme.shadow 
            }

            // Solid jagged teeth for the shadow[cite: 2]
            Row {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -10 
                anchors.left: parent.left
                Repeater {
                    model: 17 
                    Item {
                        width: 20; height: 20
                        Rectangle {
                            anchors.centerIn: parent
                            width: 14.14; height: 14.14 
                            rotation: 45
                            color: theme.shadow 
                        }
                    }
                }
            }
        }

        // --- 2. PAPER LAYER ---
        Item {
            id: paperWrapper
            height: targetPaperHeight > 0 ? targetPaperHeight : currentPaperHeight
            width: 340
            x: 10 // Centered exactly under the hardware slot
            anchors.top: parent.top

            // A. Paper Teeth (Drawn FIRST so the solid paper masks the upper half)
            Row {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -10 // Exactly centers the squares on the bottom line
                anchors.left: parent.left
                Repeater {
                    model: 17 // 17 teeth * 20px = perfectly 340px
                    Item {
                        width: 20; height: 20
                        Rectangle { 
                            anchors.centerIn: parent
                            width: 14.14; height: 14.14 
                            rotation: 45; 
                            color: theme.bgDim; 
                            border.color: theme.fgMuted; 
                            border.width: 1
                        }
                    }
                }
            }

            // B. Solid Paper Overlay (Drawn SECOND to overlap and mask the teeth)
            Rectangle {
                id: paperSolid
                anchors.fill: parent
                color: theme.bgDim

                // Side borders seamlessly meet the corners of the first and last tooth
                Rectangle { anchors.left: parent.left; width: 1; height: parent.height; color: theme.fgMuted }
                Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: theme.fgMuted }

                // Perforation holes
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
            }

            // C. Content
            Text {
                anchors.centerIn: paperSolid
                visible: printerWindow.allNotifications.length === 0
                text: "*** NO NEW LOGS ***"
                color: theme.fg
                font.family: "monospace"
                font.pixelSize: 12
                font.weight: Font.Bold
            }

            ListView {
                id: paperList
                anchors.fill: paperSolid
                anchors.bottomMargin: 12 
                anchors.leftMargin: 18; anchors.rightMargin: 18
                clip: true
                spacing: 0 
                
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
                    Text {
                        visible: parent.isTopReached
                        anchors.bottom: parent.bottom; anchors.bottomMargin: 8;
                        anchors.horizontalCenter: parent.horizontalCenter;
                        text: "========================================"
                        color: theme.fg; opacity: 0.5; font.family: "monospace"; font.pixelSize: 10
                        clip: true; width: parent.width - 24
                    }
                }

                delegate: Rectangle {
                    id: delegateRoot
                    width: ListView.view.width
                    height: delegateCol.height + 24
                    
                    color: isSelected ? theme.fg : "transparent"
                    property bool isSelected: ListView.isCurrentItem || hoverArea.containsMouse

                    function getTextColor() {
                        if (isSelected) return theme.bgDim; 
                        if (modelData.urgency === 2) return theme.red;
                        if (modelData.urgency === 0) return theme.fgMuted;
                        return theme.fg;
                    }

                    Column {
                        id: delegateCol
                        anchors.top: parent.top
                        anchors.topMargin: 12
                        anchors.left: parent.left; anchors.right: parent.right
                        anchors.leftMargin: 10; anchors.rightMargin: 10
                        spacing: 4

                        Item {
                            width: parent.width
                            height: appText.height

                            Text {
                                id: appText
                                anchors.left: parent.left
                                text: modelData.app
                                color: delegateRoot.getTextColor()
                                font.family: "monospace"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                            }

                            Text {
                                id: urgText
                                anchors.right: parent.right
                                text: modelData.urgency === 2 ? "CRT" : (modelData.urgency === 0 ? "LOW" : "NRM")
                                color: delegateRoot.getTextColor()
                                font.family: "monospace"
                                font.pixelSize: 11
                            }

                            Text {
                                anchors.left: appText.right
                                anchors.right: urgText.left
                                anchors.leftMargin: 6
                                anchors.rightMargin: 6
                                text: "................................................................................"
                                color: delegateRoot.getTextColor()
                                font.family: "monospace"
                                font.pixelSize: 11
                                opacity: 0.3
                                clip: true
                            }
                        }

                        Text {
                            text: modelData.title
                            color: delegateRoot.getTextColor()
                            font.family: "monospace"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            wrapMode: Text.Wrap
                            width: parent.width
                        }

                        Text {
                            text: modelData.body
                            color: delegateRoot.getTextColor()
                            font.family: "monospace"
                            font.pixelSize: 11
                            wrapMode: Text.Wrap
                            width: parent.width
                            opacity: delegateRoot.isSelected ? 1.0 : (modelData.urgency === 2 ? 1.0 : 0.8)
                            visible: text.length > 0
                        }
                    }

                    Text {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
                        color: delegateRoot.getTextColor()
                        font.family: "monospace"
                        font.pixelSize: 10
                        opacity: delegateRoot.isSelected ? 0.3 : 0.15
                        clip: true
                        width: parent.width - 20
                        visible: index < ListView.view.count - 1
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
        }
    }
}