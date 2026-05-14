import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Services"
import "../Widgets"

PanelWindow {
    id: wallpaperPanel

    screen: Quickshell.screens[0]
    property QtObject theme

    visible: false
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: wallpaperPanel.visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors { top: true; bottom: true; left: true; right: true }

    exclusiveZone: 0
    color: "transparent"

    WallpaperService {
        id: wallpaperService
        onWallpaperListUpdated: {
            wallpaperGrid.model = wallpaperService.wallpapers
            tabRepeater.model = wallpaperService.wallpaperTabs
            
            if (wallpaperService.wallpapers.length > 0) {
                wallpaperService.updatePreviewMetadata(wallpaperService.wallpapers[0])
            }
        }
    }

    Item {
        id: dialogWrapper
        anchors.centerIn: parent
        width: 760
        height: 540
        z: 10

        Rectangle {
            anchors.fill: dialogFrame
            anchors.topMargin: 8
            anchors.leftMargin: 8
            anchors.rightMargin: -8
            anchors.bottomMargin: -8
            color: "#333333" 
            opacity: 0.5
            z: dialogFrame.z - 1
        }

        Rectangle {
            id: dialogFrame
            anchors.fill: parent
            color: theme.bg
            border.color: theme.fg
            border.width: 2
            z: 10

            Item {
                id: innerContent
                anchors.fill: parent
                anchors.margins: 2

                Rectangle {
                    id: titleBar
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 24
                    color: theme.fg

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\\\\\\ WALLPAPER"
                        color: theme.bg
                        font.family: "monospace"
                        font.pixelSize: 11
                        font.bold: true
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.rightMargin: 4
                        anchors.verticalCenter: parent.verticalCenter
                        width: 14
                        height: 14
                        color: theme.bg
                        
                        Text {
                            anchors.centerIn: parent
                            text: "x"
                            color: theme.fg
                            font.family: "monospace"
                            font.pixelSize: 11
                            font.bold: true
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: wallpaperPanel.visible = false
                        }
                    }
                }

                Row {
                    id: rainbowStripe
                    anchors.top: titleBar.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 4
                    Rectangle { width: parent.width / 5; height: parent.height; color: theme.green }
                    Rectangle { width: parent.width / 5; height: parent.height; color: theme.blue }
                    Rectangle { width: parent.width / 5; height: parent.height; color: theme.yellow }
                    Rectangle { width: parent.width / 5; height: parent.height; color: theme.orange }
                    Rectangle { width: parent.width / 5; height: parent.height; color: theme.red }
                }

                Item {
                    id: bodyArea
                    anchors.top: rainbowStripe.bottom
                    anchors.bottom: bottomBar.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 12

                    Row {
                        id: tabBar
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 26
                        spacing: 8
                        clip: true

                        Repeater {
                            id: tabRepeater
                            model: wallpaperService.wallpaperTabs

                            Rectangle {
                                width: tabText.width + 24
                                height: 26
                                color: isSelected ? theme.blue : theme.bg
                                border.color: theme.fg
                                border.width: 2
                                property bool isSelected: wallpaperService.currentTabIndex === index

                                Text {
                                    id: tabText
                                    anchors.centerIn: parent
                                    text: modelData.name
                                    color: isSelected ? theme.bg : theme.fg
                                    font.family: "monospace"
                                    font.pixelSize: 11
                                    font.bold: isSelected
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        wallpaperService.switchTab(index)
                                        wallpaperGrid.currentIndex = 0
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: listFrame
                        anchors.top: tabBar.bottom
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.topMargin: 12
                        width: 300
                        color: theme.fg 
                        border.color: theme.fg
                        border.width: 2

                        GridView {
                            id: wallpaperGrid
                            anchors.fill: parent
                            anchors.margins: 10
                            cellWidth: 140
                            cellHeight: 100
                            clip: true

                            onCurrentIndexChanged: {
                                if (currentIndex >= 0 && wallpaperService.wallpapers[currentIndex]) {
                                    wallpaperService.updatePreviewMetadata(wallpaperService.wallpapers[currentIndex])
                                } else {
                                    wallpaperService.previewMetadata = ""
                                }
                            }

                            delegate: Rectangle {
                                id: wallpaperDelegate
                                width: wallpaperGrid.cellWidth - 10
                                height: wallpaperGrid.cellHeight - 10
                                color: "transparent"
                                border.color: isSelected ? theme.blue : "transparent"
                                border.width: 2

                                property bool isSelected: wallpaperGrid.currentIndex === index

                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 3
                                    color: theme.bgDim
                                    border.color: theme.bg
                                    border.width: 1

                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        source: "file://" + modelData
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: true
                                        
                                        // THE MAGIC FIX: 
                                        // Forces QML to decode a tiny 140x100 pixmap instead of 
                                        // loading massive raw 4K wallpapers into your RAM.
                                        sourceSize.width: 140
                                        sourceSize.height: 100
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: wallpaperGrid.currentIndex = index
                                    onDoubleClicked: wallpaperService.setWallpaperByIndex(index)
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: previewFrame
                        anchors.top: tabBar.bottom
                        anchors.bottom: parent.bottom
                        anchors.left: listFrame.right
                        anchors.right: parent.right
                        anchors.topMargin: 12
                        anchors.leftMargin: 12
                        color: theme.fg 
                        border.color: theme.fg
                        border.width: 2

                        Text {
                            text: "PREVIEW"
                            color: theme.yellow
                            font.family: "monospace"
                            font.pixelSize: 10
                            font.bold: true
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.margins: 8
                            z: 2
                        }

                        Image {
                            id: previewImage
                            anchors.fill: parent
                            anchors.margins: 28
                            anchors.bottomMargin: 40 
                            source: {
                                if (wallpaperGrid.currentIndex >= 0 && wallpaperService.wallpapers[wallpaperGrid.currentIndex]) {
                                    return "file://" + wallpaperService.wallpapers[wallpaperGrid.currentIndex]
                                }
                                return ""
                            }
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            cache: true
                            // Leaving sourceSize off here so we don't break the resolution readout below!
                        }

                        Item {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 36
                            
                            Text {
                                anchors.centerIn: parent
                                text: {
                                    if (previewImage.source == "") return ""
                                    let w = previewImage.sourceSize.width
                                    let h = previewImage.sourceSize.height
                                    let dims = (w > 0 && h > 0) ? (w + "x" + h + " | ") : ""
                                    return (dims + wallpaperService.previewMetadata).toUpperCase()
                                }
                                color: theme.bgDim
                                font.family: "monospace"
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
                    }
                }

                Item {
                    id: bottomBar
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 40

                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 2
                        color: theme.fg
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        color: theme.fg
                        font.family: "monospace"
                        font.pixelSize: 11
                        font.bold: true
                        text: {
                            let total = wallpaperService.wallpapers.length
                            if (total === 0) return "0 FILES"
                            
                            let currentPath = ""
                            if (wallpaperGrid.currentIndex >= 0 && wallpaperService.wallpapers[wallpaperGrid.currentIndex]) {
                                let path = wallpaperService.wallpapers[wallpaperGrid.currentIndex]
                                let parts = path.split('/')
                                currentPath = parts[parts.length - 1]
                            }
                            
                            return total + " FILE(S)  |  " + currentPath
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        Rectangle {
                            width: 36; height: 22
                            color: theme.bg; border.color: theme.fg; border.width: 2
                            Text { anchors.centerIn: parent; text: "[<]"; font.family: "monospace"; font.pixelSize: 11; font.bold: true; color: theme.fg }
                            MouseArea { anchors.fill: parent; onClicked: { wallpaperService.previousWallpaper(); wallpaperGrid.currentIndex = wallpaperService.currentIndex; } }
                        }

                        Rectangle {
                            width: 36; height: 22
                            color: theme.bg; border.color: theme.fg; border.width: 2
                            Text { anchors.centerIn: parent; text: "[>]"; font.family: "monospace"; font.pixelSize: 11; font.bold: true; color: theme.fg }
                            MouseArea { anchors.fill: parent; onClicked: { wallpaperService.nextWallpaper(); wallpaperGrid.currentIndex = wallpaperService.currentIndex; } }
                        }

                        Rectangle {
                            width: 64; height: 22
                            color: theme.green; border.color: theme.fg; border.width: 2
                            Text { anchors.centerIn: parent; text: "APPLY"; font.family: "monospace"; font.pixelSize: 11; font.bold: true; color: theme.bg }
                            MouseArea { 
                                anchors.fill: parent
                                onClicked: {
                                    if (wallpaperGrid.currentIndex >= 0) {
                                        wallpaperService.setWallpaperByIndex(wallpaperGrid.currentIndex)
                                    }
                                } 
                            }
                        }

                        Rectangle {
                            width: 48; height: 22
                            color: theme.bg; border.color: theme.fg; border.width: 2
                            Text { anchors.centerIn: parent; text: "ESC"; font.family: "monospace"; font.pixelSize: 11; font.bold: true; color: theme.fg }
                            MouseArea { anchors.fill: parent; onClicked: wallpaperPanel.visible = false }
                        }
                    }
                }
            }

            Keys.onPressed: (event) => {
                let cols = 2
                let count = wallpaperGrid.count
                let idx = wallpaperGrid.currentIndex
                let tabs = wallpaperService.wallpaperTabs.length

                if (event.key === Qt.Key_Escape) {
                    wallpaperPanel.visible = false
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (idx >= 0) {
                        wallpaperService.setWallpaperByIndex(idx)
                    }
                } else if (event.key === Qt.Key_Left || event.key === Qt.Key_H) {
                    if (idx > 0) wallpaperGrid.currentIndex = idx - 1
                } else if (event.key === Qt.Key_Right || event.key === Qt.Key_L) {
                    if (idx < count - 1) wallpaperGrid.currentIndex = idx + 1
                } else if (event.key === Qt.Key_Up || event.key === Qt.Key_K) {
                    if (idx >= cols) wallpaperGrid.currentIndex = idx - cols
                } else if (event.key === Qt.Key_Down || event.key === Qt.Key_J) {
                    if (idx < count - cols) wallpaperGrid.currentIndex = idx + cols
                } else if (event.key === Qt.Key_Tab) {
                    if (tabs === 0) return
                    let nextTab = (wallpaperService.currentTabIndex + 1) % tabs
                    wallpaperService.switchTab(nextTab)
                    wallpaperGrid.currentIndex = 0
                } else if (event.key === Qt.Key_Backtab) {
                    if (tabs === 0) return
                    let prevTab = (wallpaperService.currentTabIndex - 1 + tabs) % tabs
                    wallpaperService.switchTab(prevTab)
                    wallpaperGrid.currentIndex = 0
                } else if (event.key === Qt.Key_R || event.key === Qt.Key_F5) {
                    wallpaperService.loadWallpapers(true)
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (mouseX < dialogWrapper.x || mouseX > dialogWrapper.x + dialogWrapper.width ||
                mouseY < dialogWrapper.y || mouseY > dialogWrapper.y + dialogWrapper.height) {
                wallpaperPanel.visible = false
            }
        }
    }

    function toggleState() {
        wallpaperPanel.visible = !wallpaperPanel.visible
        if (wallpaperPanel.visible) {
            wallpaperService.loadWallpapers()
            dialogFrame.forceActiveFocus()
        }
    }
}