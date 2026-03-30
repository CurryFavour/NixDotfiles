import QtQuick
import Quickshell
import ".."

Item {
    id: themeManager
    
    property QtObject theme: Theme {
        id: themeInstance
    }
}
