import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    anchors.top: true
    anchors.left: true
    anchors.right: true
    visible : true
    implicitHeight: 30

    Text {
        anchors.centerIn: parent
        text: "Hello Quickshell!"
        color: "#0db9d7"
        font.pixelSize: 18
    }
}


// to run: quickshell --path ~/.config/quickshell/helloworld.qml 