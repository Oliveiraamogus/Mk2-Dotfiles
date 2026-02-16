import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import "./shell.qml"
PanelWindow{
    id: toplevel

    anchors {
        top: true
        //left: true
        //right: true
    }

    PopupWindow {
        id: callendar

        visible: true
        height: 20
    }
}