import QtQuick
import Quickshell.Hyprland

Rectangle {
    id: windowTitleWidget
    
    property QtObject theme
    
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: 1
    
    property bool isValidWindow: {
        if (!Hyprland.activeToplevel || !Hyprland.focusedWorkspace) return false;
        if (!Hyprland.activeToplevel.workspace) return false;
        return Hyprland.activeToplevel.workspace.id === Hyprland.focusedWorkspace.id;
    }

    property string rawTitle: isValidWindow ? Hyprland.activeToplevel.title : ""
    property string safeTitle: rawTitle.trim()
    property bool isEmpty: safeTitle === ""
    property int lastWs: currentWs
    property int direction: 1 
    
    property string displayTitle: "[ IDLIN ]" 
    
    Component.onCompleted: {
        displayTitle = isEmpty ? "[ IDLIN ]" : safeTitle;
    }

    property int currentWs: Hyprland.focusedMonitor ? Hyprland.focusedMonitor.activeWorkspace.id : 1

    onCurrentWsChanged: {
        titleChangeAnim.stop();
        tapeMove.y = 0; 

        direction = (currentWs >= lastWs) ? 1 : -1;
        
        leftSpinAnim.from = leftSpoolRotator.rotation;
        leftSpinAnim.to = leftSpoolRotator.rotation + (360 * direction);
        leftSpinAnim.restart();
        
        rightSpinAnim.from = rightSpoolRotator.rotation;
        rightSpinAnim.to = rightSpoolRotator.rotation + (360 * direction);
        rightSpinAnim.restart();
        
        wsChangeAnim.restart();
        lastWs = currentWs;
    }

    onSafeTitleChanged: {
        let newText = isEmpty ? "[ IDLIN ]" : safeTitle;
        
        if (!wsChangeAnim.running && displayTitle !== newText) {
            titleChangeAnim.restart();
        }
    }
        
    height: 26
    width: 340 
    
    color: theme.bgDim 
    border.color: theme.fg
    border.width: 2
    radius: 3

    Rectangle { 
        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
        anchors.margins: 2;
        height: 1; color: theme.highlight; opacity: 0.5 
    }

    Rectangle {
        anchors.centerIn: parent
        width: parent.width - 64 
        height: parent.height - 4
        color: theme.bg
        border.color: theme.fg
        border.width: 1
        radius: 2
        clip: true 

        Row {
            anchors.top: parent.top;
            anchors.topMargin: 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 12;
            height: 2 
            Rectangle { width: parent.width / 5; height: parent.height; color: theme.green }
            Rectangle { width: parent.width / 5; height: parent.height; color: theme.blue }
            Rectangle { width: parent.width / 5; height: parent.height; color: theme.yellow }
            Rectangle { width: parent.width / 5; height: parent.height; color: theme.orange }
            Rectangle { width: parent.width / 5; height: parent.height; color: theme.red }
        }
        Row {
            anchors.top: parent.top;
            anchors.topMargin: 6
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 12;
            height: 1 
            Rectangle { width: parent.width / 5; height: parent.height; color: theme.green }
            Rectangle { width: parent.width / 5; height: parent.height; color: theme.blue }
            Rectangle { width: parent.width / 5; height: parent.height; color: theme.yellow }
            Rectangle { width: parent.width / 5; height: parent.height; color: theme.orange }
            Rectangle { width: parent.width / 5; height: parent.height; color: theme.red }
        }

        Text {
            id: titleText
            text: windowTitleWidget.displayTitle
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 2 
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            
            color: windowTitleWidget.isEmpty ? theme.fgMuted : theme.fg
            font.family: "sans-serif"
            font.pixelSize: 11
            font.weight: Font.Bold
            font.italic: true 
            
            leftPadding: 8
            rightPadding: 8
            elide: Text.ElideRight

            transform: Translate { id: tapeMove }

            SequentialAnimation {
                id: wsChangeAnim
                
                NumberAnimation { 
                    target: tapeMove; 
                    property: "x"; 
                    to: titleText.width * windowTitleWidget.direction; 
                    duration: 200; 
                    easing.type: Easing.InCubic 
                }

                ScriptAction {
                    script: {
                        windowTitleWidget.displayTitle = windowTitleWidget.isEmpty ? "[ IDLIN ]" : windowTitleWidget.safeTitle;
                        tapeMove.x = -(titleText.width * windowTitleWidget.direction);
                    }
                }

                NumberAnimation { 
                    target: tapeMove; 
                    property: "x"; 
                    to: 0; 
                    duration: 250; 
                    easing.type: Easing.OutCubic 
                }
            }

            SequentialAnimation {
                id: titleChangeAnim
                
                NumberAnimation {
                    target: tapeMove
                    property: "y"
                    to: 30
                    duration: 150
                    easing.type: Easing.InQuad
                }
                
                ScriptAction {
                    script: {
                        windowTitleWidget.displayTitle = windowTitleWidget.isEmpty ? "A-SIDE: [ SYSTEM_IDLE ]" : windowTitleWidget.safeTitle;
                    }
                }
                
                NumberAnimation {
                    target: tapeMove
                    property: "y"
                    to: 0
                    duration: 200
                    easing.type: Easing.OutBack 
                }
            }
        }
    }

    Rectangle {
        anchors.left: parent.left;
        anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter
        width: 16; height: 16;
        radius: 8
        color: theme.topbarWidgetBg
        border.color: theme.fg;
        border.width: 1
        clip: true
        
        Item {
            id: leftSpoolRotator
            anchors.fill: parent
            
            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    
                    ctx.fillStyle = theme.highlight;
                    ctx.globalAlpha = 0.6;
                    ctx.beginPath();
                    ctx.moveTo(width/2, height/2);
                    ctx.arc(width/2, height/2, width/2, Math.PI / 6, Math.PI / 6 + (Math.PI / 3)); 
                    ctx.lineTo(width/2, height/2);
                    ctx.fill();
                }
                
                NumberAnimation {
                    id: leftSpinAnim
                    target: leftSpoolRotator
                    property: "rotation"
                    duration: 750
                    easing.type: Easing.OutQuint 
                    from: 0
                    to: 360
                }
            }
        }
    }

    Rectangle {
        anchors.right: parent.right;
        anchors.rightMargin: 8; anchors.verticalCenter: parent.verticalCenter
        width: 16; height: 16;
        radius: 8
        color: theme.topbarWidgetBg
        border.color: theme.fg;
        border.width: 1
        clip: true
        
        Item {
            id: rightSpoolRotator
            anchors.fill: parent
            
            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    
                    ctx.fillStyle = theme.highlight;
                    ctx.globalAlpha = 0.6;
                    ctx.beginPath();
                    ctx.moveTo(width/2, height/2);
                    ctx.arc(width/2, height/2, width/2, Math.PI / 6, Math.PI / 6 + (Math.PI / 3)); 
                    ctx.lineTo(width/2, height/2);
                    ctx.fill();
                }
                
                NumberAnimation {
                    id: rightSpinAnim
                    target: rightSpoolRotator
                    property: "rotation"
                    duration: 750
                    easing.type: Easing.OutQuint 
                    from: 0
                    to: 360
                }
            }
        }
    }
}
