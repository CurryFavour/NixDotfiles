import QtQuick
import "../Services"

Rectangle {
    id: windowTitleWidget
    
    property QtObject theme
    
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: 1

    WindowTitleService {
        id: titleLogic
    }

    property int lastWs: titleLogic.currentWs
    property int direction: 1 
    property string displayTitle: titleLogic.resolvedTitle 
    
    Connections {
        target: titleLogic

        function onCurrentWsChanged() {
            titleChangeAnim.stop();
            tapeMove.y = 0; 

            windowTitleWidget.direction = (titleLogic.currentWs >= windowTitleWidget.lastWs) ? 1 : -1;
            
            leftSpool.spin(windowTitleWidget.direction);
            rightSpool.spin(windowTitleWidget.direction);
            
            wsChangeAnim.restart();
            windowTitleWidget.lastWs = titleLogic.currentWs;
        }

        function onSafeTitleChanged() {
            if (!wsChangeAnim.running && windowTitleWidget.displayTitle !== titleLogic.resolvedTitle) {
                titleChangeAnim.restart();
            }
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
            anchors.top: parent.top; anchors.topMargin: 3
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 12; height: 2 
            Repeater {
                model: [theme.green, theme.blue, theme.yellow, theme.orange, theme.red]
                Rectangle { width: parent.width / 5; height: parent.height; color: modelData }
            }
        }

        Row {
            anchors.top: parent.top; anchors.topMargin: 6
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 12; height: 1 
            Repeater {
                model: [theme.green, theme.blue, theme.yellow, theme.orange, theme.red]
                Rectangle { width: parent.width / 5; height: parent.height; color: modelData }
            }
        }

        Text {
            id: titleText
            text: windowTitleWidget.displayTitle
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 2 
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            
            color: titleLogic.isEmpty ? theme.fgMuted : theme.fg
            font.family: "sans-serif"
            font.pixelSize: 11
            font.weight: Font.Bold
            font.italic: true 
            
            leftPadding: 8; rightPadding: 8
            elide: Text.ElideRight

            transform: Translate { id: tapeMove }

            SequentialAnimation {
                id: wsChangeAnim
                
                NumberAnimation { target: tapeMove; property: "x"; to: titleText.width * windowTitleWidget.direction; duration: 200; easing.type: Easing.InCubic }
                ScriptAction {
                    script: {
                        windowTitleWidget.displayTitle = titleLogic.resolvedTitle;
                        tapeMove.x = -(titleText.width * windowTitleWidget.direction);
                    }
                }
                NumberAnimation { target: tapeMove; property: "x"; to: 0; duration: 250; easing.type: Easing.OutCubic }
            }

            SequentialAnimation {
                id: titleChangeAnim
                
                NumberAnimation { target: tapeMove; property: "y"; to: 30; duration: 150; easing.type: Easing.InQuad }
                ScriptAction {
                    script: {
                        windowTitleWidget.displayTitle = titleLogic.isEmpty ? titleLogic.asideIdleText : titleLogic.safeTitle;
                    }
                }
                NumberAnimation { target: tapeMove; property: "y"; to: 0; duration: 200; easing.type: Easing.OutBack }
            }
        }
    }

    component TapeSpool: Rectangle {
        width: 16; height: 16; radius: 8
        color: theme.topbarWidgetBg
        border.color: theme.fg; border.width: 1
        clip: true
        
        function spin(direction) {
            spinAnim.from = rotRotator.rotation;
            spinAnim.to = rotRotator.rotation + (360 * direction);
            spinAnim.restart();
        }

        Item {
            id: rotRotator
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
            }
            
            NumberAnimation {
                id: spinAnim
                target: rotRotator
                property: "rotation"
                duration: 750
                easing.type: Easing.OutQuint 
            }
        }
    }

    TapeSpool {
        id: leftSpool
        anchors.left: parent.left; anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
    }

    TapeSpool {
        id: rightSpool
        anchors.right: parent.right; anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
    }
}