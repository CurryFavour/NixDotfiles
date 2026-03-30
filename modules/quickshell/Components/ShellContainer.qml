import QtQuick
import "../Components"

Item {
    id: shellContainer

    property QtObject theme: themeManager.theme
    property alias panelManager: panelManager

    ThemeManager {
        id: themeManager
    }

    PanelManager {
        id: panelManager
        theme: shellContainer.theme
    }
}
