import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Services"
import "../Widgets"
import "."

PopupWindow {
    id: clipboardWindow

    implicitWidth: 420
    implicitHeight: 560

    titleBar.title: "\\\\\\ CLIPBOARD"

    Timer {
        id: focusTimer
        interval: 50
        onTriggered: searchInput.forceFocus()
    }

    onOpened: {
        clipboardService.loadHistory()
        searchInput.clearText()
        previewScreen.previewText = "[ WAITING FOR CLIPBOARD... ]"
        focusTimer.start()
    }

    ClipboardService {
        id: clipboardService
        onFilterUpdated: (filteredHistory) => {
            historyList.items = filteredHistory
            historyList.currentIndex = 0
        }
        onPreviewUpdated: (previewText) => {
            previewScreen.previewText = previewText
        }
    }

    contentArea.children: [
        ModularSearch {
            id: searchInput
            theme: clipboardWindow.theme
            prompt: ">"
            bgColor: clipboardWindow.theme.clipboardBg
            promptColor: clipboardWindow.theme.clipboardPrompt
            textColor: clipboardWindow.theme.clipboardText
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            onFilterChanged: (query) => clipboardService.updateFilter(query)
            onNavigationRequested: (direction) => {
                if (direction === "up") historyList.decrementCurrentIndex()
                else if (direction === "down") historyList.incrementCurrentIndex()
            }
            onExecuteRequested: {
                if (historyList.items.length > 0) {
                    clipboardService.copyItem(historyList.items[historyList.currentIndex].raw)
                    clipboardWindow.toggleState()
                }
            }
            onEscapeRequested: clipboardWindow.toggleState()
        },

        Rectangle {
            id: listScreen
            anchors.top: searchInput.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: previewScreen.top
            anchors.margins: 16
            anchors.topMargin: 12
            anchors.bottomMargin: 12
            color: clipboardWindow.theme.clipboardBg
            border.color: clipboardWindow.theme.fg
            border.width: 2

            HistoryList {
                id: historyList
                theme: clipboardWindow.theme
                anchors.fill: parent
                anchors.margins: 4
                showIds: true
                onItemSelected: (index, item) => {
                    clipboardService.copyItem(item.raw)
                    clipboardWindow.toggleState()
                }
                onPreviewRequested: (text) => {
                    previewScreen.previewText = text
                }
            }
        },

        PreviewScreen {
            id: previewScreen
            theme: clipboardWindow.theme
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 16
            anchors.bottomMargin: 12
            title: "PREVIEW"
        }
    ]

    bezel.buttons: [
        { label: "[ ^ ]", action: "up" },
        { label: "[ v ]", action: "down" },
        { label: "COPY", baseColor: clipboardWindow.theme.green, action: "execute" },
        { label: "WIPE", baseColor: clipboardWindow.theme.red, action: "wipe" },
        { label: "ESC", action: "escape" }
    ]

    bezel.onActionTriggered: (actionName) => {
        switch(actionName) {
            case "up":
            case "down":
                if (actionName === "up") historyList.decrementCurrentIndex()
                else historyList.incrementCurrentIndex()
                searchInput.forceFocus()
                break
            case "execute":
                if (historyList.items.length > 0) {
                    clipboardService.copyItem(historyList.items[historyList.currentIndex].raw)
                    clipboardWindow.toggleState()
                }
                break
            case "wipe":
                clipboardService.wipeHistory()
                searchInput.forceFocus()
                break
            case "escape":
                clipboardWindow.toggleState()
                break
        }
    }
}
