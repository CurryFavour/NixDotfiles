import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../Widgets"
import "."

PopupWindow {
    id: launcherWindow

    implicitWidth: 380
    implicitHeight: 460

    property string currentQuery: ""

    property var allApps: {
        if (typeof DesktopEntries === 'undefined' || !DesktopEntries.applications) return []
        return [...DesktopEntries.applications.values].sort((a, b) => a.name.localeCompare(b.name))
    }

    property var filteredApps: {
        let q = currentQuery.trim().toLowerCase()
        return q === "" ? allApps : allApps.filter(app => app.name && app.name.toLowerCase().includes(q))
    }

    titleBar.title: "\\\\\\ LAUNCHER"

    onOpened: {
        searchInput.clearText()
        currentQuery = ""
    }

    function updateFilter(query) {
        currentQuery = query
        appList.currentIndex = 0
    }

    function executeApp(index) {
        if (filteredApps.length > 0 && index >= 0 && index < filteredApps.length) {
            filteredApps[index].execute()
        }
    }

    contentArea.children: [
        ModularSearch {
            id: searchInput
            theme: launcherWindow.theme
            bgColor: launcherWindow.theme.launcherBg
            promptColor: launcherWindow.theme.launcherPrompt
            textColor: launcherWindow.theme.launcherText
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            onFilterChanged: (query) => launcherWindow.updateFilter(query)
            onNavigationRequested: (direction) => {
                if (direction === "up") appList.decrementCurrentIndex()
                else if (direction === "down") appList.incrementCurrentIndex()
            }
            onExecuteRequested: {
                executeApp(appList.currentIndex)
                launcherWindow.toggleState()
            }
            onEscapeRequested: launcherWindow.toggleState()
        },

        AppList {
            id: appList
            theme: launcherWindow.theme
            apps: launcherWindow.filteredApps 
            anchors.top: searchInput.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: 12
            onAppSelected: (index) => {
                executeApp(index)
                launcherWindow.toggleState()
            }
        }
    ]

    bezel.buttons: [
        { label: "[ ^ ]", action: "up" },
        { label: "[ v ]", action: "down" },
        { label: "RUN", baseColor: launcherWindow.theme.green, action: "execute" },
        { label: "ESC", action: "escape" }
    ]

    bezel.onActionTriggered: (actionName) => {
        switch(actionName) {
            case "up":
            case "down":
                if (actionName === "up") appList.decrementCurrentIndex()
                else appList.incrementCurrentIndex()
                searchInput.forceActiveFocus()
                break
            case "execute":
                executeApp(appList.currentIndex)
                launcherWindow.toggleState()
                break
            case "escape":
                launcherWindow.toggleState()
                break
        }
    }
}
