import QtQuick
import "../Panels"

Item {
    id: panelManager
    property QtObject theme

    property var launcher: null
    property var clipboard: null
    property var notifications: null
    property var wallpaper: null

    Component.onCompleted: {
        createPanels()
    }

    onThemeChanged: {
        if (theme && !launcher) createPanels()
    }

    function createPanels() {
        if (!theme || launcher) return
        launcher = launcherComponent.createObject(panelManager, { theme: theme })
        clipboard = clipboardComponent.createObject(panelManager, { theme: theme })
        notifications = notificationsComponent.createObject(panelManager, { theme: theme })
        wallpaper = wallpaperComponent.createObject(panelManager, { theme: theme })
    }

    Component {
        id: launcherComponent
        AppLauncher {}
    }

    Component {
        id: clipboardComponent
        ClipboardManager {}
    }

    Component {
        id: notificationsComponent
        Notifications {}
    }

    Component {
        id: wallpaperComponent
        WallpaperPanel {}
    }
}
