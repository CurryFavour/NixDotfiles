import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: wallpaperService

    property string currentWallpaper: ""
    property var wallpapers: []  
    property var wallpaperTabs: []  
    property int currentIndex: 0
    property int currentTabIndex: 0
    property string wallpaperDir: Qt.resolvedUrl("~/Pictures/Wallpapers")
    
    property string previewMetadata: ""
    
    // --- CACHING PROPERTIES ---
    property bool isLoaded: false
    property var metadataCache: ({}) 

    signal wallpaperChanged(string path)
    signal wallpaperListUpdated()

    Process {
        id: wallpaperProcess
        command: ["swww", "img", "", "--transition-type", "wipe", "--transition-angle", "30"]
        stdout: StdioCollector {
            onStreamFinished: console.log("Wallpaper stdout:", text || "(empty)")
        }
        stderr: StdioCollector {
            onStreamFinished: console.log("Wallpaper stderr:", text || "(empty)")
        }
    }

    Process {
        id: metaProcess
        property string currentTarget: ""
        command: [
            "sh", 
            "-c", 
            "if [ -f \"$1\" ]; then size=$(du -h \"$1\" | cut -f1); format=$(file -b \"$1\" | cut -d',' -f1); echo \"$size | $format\"; fi", 
            "--", 
            currentTarget
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let result = (text || "").trim()
                wallpaperService.previewMetadata = result
                
                // Save to cache so we never have to run the shell command for this file again
                let tempCache = wallpaperService.metadataCache
                tempCache[metaProcess.currentTarget] = result
                wallpaperService.metadataCache = tempCache 
            }
        }
    }

    Process {
        id: listProcess
        command: [
            "sh",
            "-c",
            "find /home/puppy/Pictures/Wallpapers -type f 2>/dev/null | grep -iE '\\.(jpg|jpeg|png|webp)$'"
        ]
        stdout: StdioCollector {
            id: listStdout
            onStreamFinished: {
                let text = listStdout.text || ""
                let lines = text.trim().split('\n').filter(p => p.length > 0)
                
                let tabs = {}
                let basePath = "/home/puppy/Pictures/Wallpapers/"
                
                for (let line of lines) {
                    let fullPath = line.trim()
                    if (!fullPath || !fullPath.startsWith(basePath)) continue
                    
                    let relPath = fullPath.substring(basePath.length)
                    let parts = relPath.split('/')
                    
                    let folderName = (parts.length === 1) ? "unsorted" : parts[0]
                    
                    if (!tabs[folderName]) tabs[folderName] = []
                    tabs[folderName].push(fullPath)
                }
                
                let tabArray = []
                let sortedNames = Object.keys(tabs).sort()
                
                if (sortedNames.includes("unsorted")) {
                    sortedNames = sortedNames.filter(n => n !== "unsorted")
                    sortedNames.push("unsorted")
                }
                
                for (let name of sortedNames) {
                    tabArray.push({ name: name, wallpapers: tabs[name] })
                }
                
                wallpaperService.wallpaperTabs = tabArray
                
                if (tabArray.length > 0) {
                    wallpaperService.currentTabIndex = 0
                    wallpaperService.wallpapers = tabArray[0].wallpapers
                    
                    if (wallpaperService.wallpapers.length > 0 && wallpaperService.currentWallpaper === "") {
                        wallpaperService.currentIndex = 0
                        wallpaperService.currentWallpaper = wallpaperService.wallpapers[0]
                    }
                } else {
                    wallpaperService.wallpapers = []
                }
                
                // Mark as fully loaded so it caches the list
                wallpaperService.isLoaded = true
                wallpaperService.wallpaperListUpdated()
            }
        }
    }

    // Now accepts a "forceRefresh" argument
    function loadWallpapers(forceRefresh = false) {
        if (isLoaded && !forceRefresh) {
            // Already cached, just skip
            return;
        }
        listProcess.running = true
    }

    function switchTab(tabIndex) {
        if (tabIndex < 0 || tabIndex >= wallpaperTabs.length) return
        currentTabIndex = tabIndex
        wallpapers = wallpaperTabs[tabIndex].wallpapers
        currentIndex = 0
        wallpaperListUpdated()
    }

    function setWallpaper(path) {
        if (!path || path === currentWallpaper) return
        currentWallpaper = path
        wallpaperProcess.command = ["swww", "img", path, "--transition-type", "wipe", "--transition-angle", "30"]
        wallpaperProcess.running = true
        wallpaperChanged(path)
    }

    function nextWallpaper() {
        if (wallpapers.length === 0) return
        currentIndex = (currentIndex + 1) % wallpapers.length
        setWallpaper(wallpapers[currentIndex])
    }

    function previousWallpaper() {
        if (wallpapers.length === 0) return
        currentIndex = (currentIndex - 1 + wallpapers.length) % wallpapers.length
        setWallpaper(wallpapers[currentIndex])
    }

    function setWallpaperByIndex(index) {
        if (index < 0 || index >= wallpapers.length) return
        currentIndex = index
        setWallpaper(wallpapers[index])
    }

    function updatePreviewMetadata(path) {
        if (!path) {
            previewMetadata = ""
            return
        }
        
        // 1. Check if we already have this in the memory cache
        if (metadataCache[path]) {
            previewMetadata = metadataCache[path]
            return
        }
        
        // 2. If not, spawn the process to fetch it
        metaProcess.currentTarget = path
        metaProcess.running = true
    }

    Component.onCompleted: {
        loadWallpapers()
    }
}