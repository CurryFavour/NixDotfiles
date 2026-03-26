import QtQuick

Rectangle {
    id: clockWidget
    
    property QtObject theme
    
    width: 64
    height: 26
    anchors.verticalCenter: parent.verticalCenter
    
    color: theme.bgDim 
    border.color: theme.fg
    border.width: 2
    radius: 3

    Rectangle { 
        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
        anchors.margins: 2; height: 1; color: theme.highlight; opacity: 0.5 
    }

    Rectangle {
        anchors.centerIn: parent
        width: parent.width - 10
        height: parent.height - 8
        color: theme.topbarWidgetBg
        border.color: theme.fg
        border.width: 1
        radius: 2
        clip: true

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height / 2
            color: theme.bg
            opacity: 0.15
        }

        Row {
            anchors.centerIn: parent
            spacing: 1

            Text {
                id: hoursText
                text: Qt.formatTime(new Date(), "hh")
                color: theme.orange
                font.family: "sans-serif"
                font.pixelSize: 12
                font.weight: Font.Bold
            }
            
            Text {
                id: colonText
                text: ":"
                color: theme.orange
                font.family: "sans-serif"
                font.pixelSize: 12
                font.weight: Font.Bold
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -1 
                
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    PropertyAction { value: 1 }
                    PauseAnimation { duration: 500 }
                    PropertyAction { value: 0 }
                    PauseAnimation { duration: 500 }
                }
            }
            
            Text {
                id: minutesText
                text: Qt.formatTime(new Date(), "mm")
                color: theme.orange
                font.family: "sans-serif"
                font.pixelSize: 12
                font.weight: Font.Bold
            }
        }
    }

    Timer { 
        interval: 1000; running: true; repeat: true; 
        onTriggered: {
            let d = new Date();
            hoursText.text = Qt.formatTime(d, "hh");
            minutesText.text = Qt.formatTime(d, "mm");
        } 
    }
}
