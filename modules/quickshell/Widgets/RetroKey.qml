import QtQuick

Item {
    id: btnRoot
    
    property QtObject theme
    property string text: ""
    property color baseColor: theme.bgDim 
    property color fgColor: theme.fg
    
    property bool isActive: false 
    property bool _autoPressed: false 
    
    property int keyWidth: 28 
    property int shadowDepth: 2 
    
    signal clicked() 

    width: keyWidth + shadowDepth
    height: 22 + shadowDepth 

    onIsActiveChanged: {
        if (isActive) {
            clickAnim.restart()
        }
    }

    SequentialAnimation {
        id: clickAnim
        PropertyAction { target: btnRoot; property: "_autoPressed"; value: true }
        PauseAnimation { duration: 100 }
        PropertyAction { target: btnRoot; property: "_autoPressed"; value: false }
    }

    Rectangle {
        width: parent.width - btnRoot.shadowDepth
        height: parent.height - btnRoot.shadowDepth
        x: btnRoot.shadowDepth
        y: btnRoot.shadowDepth
        color: theme.fg
        radius: 3 
    }

    Rectangle {
        width: parent.width - btnRoot.shadowDepth
        height: parent.height - btnRoot.shadowDepth
        
        x: (hoverArea.pressed || btnRoot._autoPressed) ? btnRoot.shadowDepth : 0
        y: (hoverArea.pressed || btnRoot._autoPressed) ? btnRoot.shadowDepth : 0
        
        Behavior on x { NumberAnimation { duration: 100; easing.type: Easing.OutBounce } }
        Behavior on y { NumberAnimation { duration: 100; easing.type: Easing.OutBounce } }
        
        color: btnRoot.baseColor
        border.color: theme.fg
        border.width: 2
        radius: 3

        Rectangle {
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
            anchors.margins: 2; height: 1; radius: 1
            color: theme.highlight
            opacity: (hoverArea.pressed || btnRoot._autoPressed) ? 0.0 : 0.4 
        }

        Rectangle {
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
            anchors.margins: 2; height: 2; radius: 1
            color: theme.shadow
            opacity: (hoverArea.pressed || btnRoot._autoPressed) ? 0.2 : 0.0 
        }

        Text {
            anchors.centerIn: parent
            text: btnRoot.text
            color: btnRoot.fgColor
            font.family: "sans-serif" 
            font.pixelSize: 12 
            font.weight: Font.Bold 
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: btnRoot.clicked()
    }
}
