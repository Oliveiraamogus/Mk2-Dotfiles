pragma Singleton

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

FloatingWindow {
    id: themes
    visible: false

    FileView {
        id: jsonFile
        path: "/home/manel/.config/themes/current.json"
        

        blockLoading: true

    }

    readonly property var jsonData: JSON.parse(jsonFile.text())

    color: jsonData.colors.secondary
    
    //For debugging
    // Text {
        // anchors.centerIn: parent
        // color: jsonData.colors.primary 
        // text: jsonData.colors.primary
        // 
    // }

}