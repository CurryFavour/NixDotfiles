import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: appService
    
    property var allApps: []
    property var filteredApps: allApps
    
    signal filterUpdated(var filteredApps)
    
    Component.onCompleted: {
        if (typeof DesktopEntries !== 'undefined' && DesktopEntries.applications) {
            allApps = [...DesktopEntries.applications.values].sort((a, b) => a.name.localeCompare(b.name));
            filteredApps = allApps;
        }
    }
    
    function updateFilter(query) {
        let q = query.trim().toLowerCase();
        filteredApps = q === "" ? allApps : allApps.filter(app => app.name && app.name.toLowerCase().includes(q));
        filterUpdated(filteredApps);
    }
    
    function executeApp(index) {
        if (filteredApps.length > 0 && index >= 0 && index < filteredApps.length) {
            filteredApps[index].execute();
        }
    }
}
